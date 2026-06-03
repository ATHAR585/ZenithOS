EXTREMEKRNL_REPO="https://github.com/ATHAR585/ExtremeKernel-N"
EXTREMEKRNL_BRANCH="OneUI7"

EXTREMEKRNL_REPO="${EXTREMEKRNL_REPO%/}"

BUILD_KERNEL()
{
    local PARENT

    PARENT="$(pwd)"
    cd "$KERNEL_TMP_DIR" || ABORT "Could not enter kernel directory: $KERNEL_TMP_DIR"

    EVAL "./build.sh -m \"${TARGET_CODENAME}\" -k y -r n"

    cd "$PARENT" || ABORT "Could not return to previous directory: $PARENT"
}

SAFE_PULL_CHANGES()
{
    set -eo pipefail

    local PARENT
    local LOCAL
    local REMOTE
    local BASE

    PARENT="$(pwd)"
    cd "$KERNEL_TMP_DIR" || ABORT "Could not enter kernel directory: $KERNEL_TMP_DIR"

    EVAL "git fetch origin \"$EXTREMEKRNL_BRANCH\""

    LOCAL="$(git rev-parse @)"
    REMOTE="$(git rev-parse "origin/$EXTREMEKRNL_BRANCH")"
    BASE="$(git merge-base @ "origin/$EXTREMEKRNL_BRANCH")"

    if [[ "$LOCAL" == "$REMOTE" ]]; then
        LOG "- Local kernel source is up-to-date."
    elif [[ "$LOCAL" == "$BASE" ]]; then
        LOG "- Fast-forward possible. Pulling latest kernel changes."
        EVAL "git pull --ff-only origin \"$EXTREMEKRNL_BRANCH\""
    elif [[ "$REMOTE" == "$BASE" ]]; then
        LOGW "- Local kernel source is ahead of remote. Skipping pull."
    else
        cd "$PARENT" || true
        ABORT "Kernel remote history has diverged. Clean the kernel tmp directory or rebase local changes."
    fi

    EVAL "git submodule update --init --recursive"

    cd "$PARENT" || ABORT "Could not return to previous directory: $PARENT"
}

REPLACE_KERNEL_BINARIES()
{
    local KERNEL_TMP_DIR="$KERNEL_TMP_DIR-$TARGET_PLATFORM"
    local CURRENT_URL
    local CURRENT_BRANCH
    local OUT_DIR

    OUT_DIR="$KERNEL_TMP_DIR/build/out/$TARGET_CODENAME"

    [[ -d "$KERNEL_TMP_DIR" ]] || mkdir -p "$KERNEL_TMP_DIR"

    if [[ -d "$KERNEL_TMP_DIR/.git" ]]; then
        CURRENT_URL="$(git -C "$KERNEL_TMP_DIR" remote get-url origin 2>/dev/null || true)"
        CURRENT_URL="${CURRENT_URL%/}"

        CURRENT_BRANCH="$(git -C "$KERNEL_TMP_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

        if [[ "$CURRENT_URL" != "$EXTREMEKRNL_REPO" ]]; then
            LOGW "- Kernel repo URL mismatch. Recloning kernel source."
            rm -rf "$KERNEL_TMP_DIR"
        elif [[ "$CURRENT_BRANCH" != "$EXTREMEKRNL_BRANCH" ]]; then
            LOGW "- Kernel branch mismatch. Recloning kernel source."
            rm -rf "$KERNEL_TMP_DIR"
        else
            LOG "- Existing ExtremeKernel source found. Checking for updates."
            if ! SAFE_PULL_CHANGES; then
                ABORT "Could not update ExtremeKernel source. If you have local changes, rebase them. Otherwise delete the kernel tmp directory."
            fi
        fi
    fi

    if [[ ! -d "$KERNEL_TMP_DIR/.git" ]]; then
        LOG "- Cloning ExtremeKernel-N branch $EXTREMEKRNL_BRANCH"
        EVAL "git clone --branch \"$EXTREMEKRNL_BRANCH\" --single-branch --recurse-submodules \"$EXTREMEKRNL_REPO\" \"$KERNEL_TMP_DIR\""
    fi

    LOG "- Running ExtremeKernel build script."
    BUILD_KERNEL

    for i in "boot" "dtb" "dtbo"; do
        if [[ ! -f "$OUT_DIR/$i.img" ]]; then
            ABORT "Kernel build failed: missing $OUT_DIR/$i.img"
        fi

        [[ -f "$WORK_DIR/kernel/$i.img" ]] && rm -f "$WORK_DIR/kernel/$i.img"
        mv -f "$OUT_DIR/$i.img" "$WORK_DIR/kernel/$i.img"
    done

    LOG "- ExtremeKernel binaries replaced successfully."
}

REPLACE_KERNEL_BINARIES