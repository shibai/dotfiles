function brazil_workspace_path() {
    brazil=$(pwd)
    while [[ -n $brazil ]]
    do
        if [[ -e "${brazil}/packageInfo" ]] then
            break
        fi
        brazil=${brazil%/*}
    done

    echo $brazil
}

function brazil_workspace_dir() {
    echo ${$(brazil_workspace_path)##*/}
}

function brazil_package() {
    package="${PWD#$(brazil_workspace_path)/src/}"
    if [[ "$package" = "/#" ]] then
        echo ""
    else
        echo ${package%%/*}
    fi
}

function cd_brazil_package() {
    local package=$1
    if [[ -z $package ]]; then
        cd $(brazil_package_path)
    elif [[ -d $(brazil_workspace_path)/src/$package ]]; then
        cd $(brazil_workspace_path)/src/$package
    else
        echo "Unknown package: $package"
    fi
}

function _cd_brazil_package() {
    local rootdir=$(brazil_workspace_path)
    local ret=1
    if [[ -n rootdir ]]; then
        _arguments \
            '1:file: _files -W ${rootdir}/src -/' && ret=0
    fi

    return ret
}


function cd_brazil_workspace() {
    local workspace=$1
    if [[ -z $workspace ]]; then
        cd $(brazil_workspace_path)
    elif [[ -d $(brazil_workspace_path)/../$workspace ]]; then
        cd $(brazil_workspace_path)/../$workspace
    else
        echo "Unknown workspace: $workspace"
    fi
}

function _cd_brazil_workspace() {
    local rootdir=$(brazil_workspace_path)
    local ret=1
    if [[ -n rootdir ]]; then
        _arguments \
            '1:file: _files -W ${rootdir}/.. -/' && ret=0
    fi

    return ret
}

function brazil_package_path() {
    echo "$(brazil_workspace_path)/src/$(brazil_package)"
}

function brazil_package_local_path() {
    echo ${${PWD#$(brazil_package_path)}#/}
}

function brazil_workspace_packages() {
    for dir in $(brazil_workspace_package_paths)
    do
        echo ${dir##*/}
    done
}

function brazil_workspace_package_paths() {
    local wsdir=$(brazil_workspace_path)
    find $wsdir/src -maxdepth 1 -mindepth 1 -type d | sort
}

alias bb=brazil-build
alias bbr='brazil-recursive-cmd --recAllDeps brazil-build'
