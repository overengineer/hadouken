# ______________________________________________________
# Contains helper functions to invoke common git commands in CMake.
# 
# @file 		GitHelper.cmake
# @author 		Mustafa Kemal GILOR <mgilor@nettsi.com>
# @date 		14.02.2020
# 
# @copyright   2020 NETTSI Informatics Technology Inc.
# 
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# ______________________________________________________

function (git_get_branch_name)
    cmake_parse_arguments(ARGS "" "" "DIRECTORY;" ${ARGN})
    if(NOT ARGS_DIRECTORY)
        message(FATAL_ERROR "GitGetBranchName() requires a directory. Please specify it by adding DIRECTORY argument to your function call.")
    endif()
    execute_process(
        COMMAND git symbolic-ref -q --short HEAD
        WORKING_DIRECTORY ${ARGS_DIRECTORY}
        OUTPUT_VARIABLE GIT_BRANCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        OUTPUT_QUIET
        ERROR_QUIET
    )
    set(GIT_BRANCH_NAME ${GIT_BRANCH} PARENT_SCOPE)
    set_property(GLOBAL PROPERTY GIT_BRANCH_NAME ${GIT_BRANCH})
endfunction()

function (git_get_head_commit_hash)
    cmake_parse_arguments(ARGS "" "" "DIRECTORY;" ${ARGN})
    if(NOT ARGS_DIRECTORY)
        message(FATAL_ERROR "GitGetHeadCommitHash() requires a directory. Please specify it by adding DIRECTORY argument to your function call.")
    endif()
    execute_process(
        COMMAND git rev-parse --verify HEAD
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        RESULT_VARIABLE GIT_RESULT_VAR
        OUTPUT_VARIABLE GIT_COMMIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        OUTPUT_QUIET
        ERROR_QUIET
  )
    if(GIT_RESULT_VAR EQUAL "0")
        set(GIT_HEAD_COMMIT_HASH ${GIT_COMMIT_HASH} PARENT_SCOPE)
        set_property(GLOBAL PROPERTY GIT_HEAD_COMMIT_HASH ${GIT_COMMIT_HASH})
    else()
        set(GIT_HEAD_COMMIT_HASH "N/A" PARENT_SCOPE)
        set_property(GLOBAL PROPERTY GIT_HEAD_COMMIT_HASH "N/A")
    endif()
endfunction()

function (git_is_worktree_dirty)
    cmake_parse_arguments(ARGS "" "" "DIRECTORY;" ${ARGN})
    if(NOT ARGS_DIRECTORY)
        message(FATAL_ERROR "GitIsWorktreeDirty() requires a directory. Please specify it by adding DIRECTORY argument to your function call.")
    endif()
    execute_process(
        COMMAND git diff-index --quiet HEAD --
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        RESULT_VARIABLE GIT_WORKTREE_DIRTY
        OUTPUT_STRIP_TRAILING_WHITESPACE
        OUTPUT_QUIET
        ERROR_QUIET
  )
  
  if(GIT_WORKTREE_DIRTY)
    set(GIT_IS_WORKTREE_DIRTY true PARENT_SCOPE)
    set_property(GLOBAL PROPERTY GIT_IS_WORKTREE_DIRTY true)
  else()
    set(GIT_IS_WORKTREE_DIRTY false PARENT_SCOPE)
    set_property(GLOBAL PROPERTY GIT_IS_WORKTREE_DIRTY false)
  endif()
endfunction()

function (git_get_config)
    cmake_parse_arguments(ARGS "" "" "DIRECTORY;CONFIG_KEY;" ${ARGN})
    if(NOT ARGS_DIRECTORY)
        message(FATAL_ERROR "GitConfigGet() requires a directory. Please specify it by adding DIRECTORY argument to your function call.")
    endif()
    if(NOT ARGS_CONFIG_KEY)
        message(FATAL_ERROR "GitConfigGet() requires a config key. Please specify it by adding CONFIG_KEY argument to your function call.")
    endif()
    execute_process(
        COMMAND git config --get ${ARGS_CONFIG_KEY}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_CONFIG_VALUE
        OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  string(REPLACE "." "_" CONFIG_KEY_NORMALIZED ${ARGS_CONFIG_KEY})
  string(TOUPPER ${CONFIG_KEY_NORMALIZED} CONFIG_KEY_NORMALIZED)

  set(GIT_CONFIG_${CONFIG_KEY_NORMALIZED} ${GIT_CONFIG_VALUE} PARENT_SCOPE)
  set_property(GLOBAL PROPERTY GIT_CONFIG_${CONFIG_KEY_NORMALIZED} ${GIT_CONFIG_VALUE})
endfunction()

function (git_print_status)
    message(STATUS "[*] VCS status")
    git_get_branch_name(
        DIRECTORY ${CMAKE_SOURCE_DIR}
    )
    git_get_head_commit_hash(
        DIRECTORY ${CMAKE_SOURCE_DIR}
    )

    git_is_worktree_dirty(
        DIRECTORY ${CMAKE_SOURCE_DIR}
    )

    message(STATUS "\tBranch: ${GIT_BRANCH_NAME}")
    message(STATUS "\tCommit: ${GIT_HEAD_COMMIT_HASH}")
    message(STATUS "\tDirty: ${GIT_IS_WORKTREE_DIRTY}")
endfunction()


function (git_export_to_macro)
    git_get_branch_name(
        DIRECTORY ${CMAKE_SOURCE_DIR}
    )

    git_get_head_commit_hash(
        DIRECTORY ${CMAKE_SOURCE_DIR}
    )

    git_is_worktree_dirty(
        DIRECTORY ${CMAKE_SOURCE_DIR}
    )

    git_get_config(
        DIRECTORY ${CMAKE_SOURCE_DIR}
        CONFIG_KEY user.name    
    )

    git_get_config(
        DIRECTORY ${CMAKE_SOURCE_DIR}
        CONFIG_KEY user.email    
    )

    add_compile_definitions(SPECTRE_GIT_BRANCH_NAME="${GIT_BRANCH_NAME}")
    add_compile_definitions(SPECTRE_GIT_COMMIT_ID="${GIT_HEAD_COMMIT_HASH}")
    add_compile_definitions(SPECTRE_GIT_WORKTREE_DIRTY="${GIT_IS_WORKTREE_DIRTY}")
    add_compile_definitions(SPECTRE_GIT_AUTHOR_NAME="${GIT_CONFIG_USER_NAME}")
    add_compile_definitions(SPECTRE_GIT_AUTHOR_EMAIL="${GIT_CONFIG_USER_EMAIL}")
endfunction()
