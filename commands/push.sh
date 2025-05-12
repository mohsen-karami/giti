#!/bin/bash


# generate_comment_label: Prompt user to select a commit type and assign the corresponding label.
# This function helps maintain standardized commit messages by enforcing conventional commit types.

generate_comment_label () {
  printf "\e[1;93mSelect the type of change you are committing:\n\e[1;0m"

  task_options=(
    "fix: Fixes a bug"
    "feat: Adds a new feature"
    "perf: Optimizes performance"
    "test: Adds or modifies tests"
    "docs: Updates or improves documentation"
    "build: Changes build system or dependencies"
    "ci: Updates CI/CD configurations or pipelines"
    "style: Updates code formatting without functional changes"
    "refactor: Improves code structure without altering functionality"
    "chore: General upkeep tasks, including configuration changes and dependency management"
  )

  select_option "${task_options[@]}"
  index=$?
  labels=("feat: " "fix: " "style: " "chore: " "refactor: " "test: " "docs: " "build: " "perf: " "ci: ")
  label=${labels[$index]}

  # Prompt the user to optionally enter a scope for the commit
  printf "\e[1;93mOptionally, enter a scope for this commit (e.g., 'auth', 'ui', etc.):\n\e[1;94m"
  printf "Press Enter to skip this step.\n\e[0;90m"
  read -e scope

  # If a scope is provided, format it and append it to the label
  if [[ ! -z $scope ]]; then
    scope="($scope): "
    label=${label/$": "/$scope}
  fi
}

generate_comment_title () {
  index=1
  printf "\e[1;93mEnter your commit message:\n\e[0;90m"
  read -e -a title_array
  while [ -z ${title_array} ]; do
    ((index++))
    printf "\n\n\e[1;31mSorry, but the commit message is required.\e[0;39m\n"
    if (( index>3 )); then
      printf "\e[1;31mThe script has stopped running because the user refused to enter the commit message that is a required input.\e[0;39m\n"
      exit 2
    else
      printf "\e[1;93mEnter your commit message:\n\e[0;90m"
      read -e -a title_array
    fi
  done
  title=${title_array[*]}
  title="$(tr '[:lower:]' '[:upper:]' <<< ${title:0:1})${title:1}"
}

# generate_comment_body : Collects a detailed commit description and optional issue tracker link from the user.

generate_comment_body () {
  printf "\e[1;93mPlease provide a detailed description for your commit. Multi-line input is supported.\n\e[0;90m"
  printf "\e[1;94mNote: This step is optional; Press Enter to skip.\n\e[0;90m"
  printf "\e[1;94mIf you choose to provide input, press Enter twice consecutively with a brief pause to finalize your description.\n\e[0;90m"

  description=""
  second_enter=0

  while true; do
    first_enter=$(date +%s)
    # Read input, allowing both manual multi-line input and pasted multi-line text
    IFS= read -r line

    if [[ -z $line ]]; then
      second_enter=$(date +%s)
      # Break if the user presses Enter twice consecutively with a brief pause
      if (( $second_enter - $first_enter < 1 )); then
        break
      fi
    else
      # Capitalize the first letter of each line
      line="$(tr '[:lower:]' '[:upper:]' <<< ${line:0:1})${line:1}"
      description+="$line"$'\n'
    fi

  done

  printf "\e[1;93mIf applicable, provide a link to the related issue tracker:\n\e[0;90m"
  printf "\e[1;94mThis step is optional. Press Enter to skip.\n\e[0;90m"
  read -e link
  # Ensure the link starts with "http" for proper formatting.
  if [[ ! -z $link ]]; then
    if [[ ${link:0:4} != "http" ]]; then
      link="https://"$link
    fi
    link="Reference: "$link
  fi

  # Combine the description and link into the commit body, if provided.
  if [[ ! -z $description ]] && [[ ! -z $link ]]; then
    body=$description$'\n\n'$link
  elif [[ ! -z $description ]] || [[ ! -z $link ]]; then
    body=$description$link
  fi
}


override_commits () {
  # show a warning message that inform the user about the danger of their process
  printf "\e[1;31mNote:\e[0;39m your current branch is \e[1m$BRANCH\e[0m, are you sure to continue?(y/n)"
  read agreement
  agreement=${agreement:-y}
  if [ $agreement == y ]; then
    if $is_wd_clean ; then
      NUMBER="${REVISE:-$MERGE}"
      # check if there are some new commits on the remote branch
      if [[ $MERGE ]]; then
        printf "\e[1;92mThe working tree is clean; in such cases, it's better to run \e[7mgiti push -r $NUMBER\e[27m instead.\n\e[0;90m"
      fi
      if [ $NUMBER == 1 ]; then
        printf "\e[1;96mFetching the last commit from the remote server.\n\e[0;90m"
      else
        printf "\e[1;96mFetching the last $NUMBER commits from the remote server.\n\e[0;90m"
      fi
      git reset HEAD~$NUMBER
    else
      if [[ $MERGE ]]; then
        git reset HEAD~$MERGE
      else
        printf "\e[1;1mPlease stash your changes or revert them before you override the previous commit(s)\n\e[0;90m"
        printf "\e[1;96mIf you wanna merge the commit(s) with your current working tree changes, run \e[7mgiti push -m $REVISE\e[27m instead.\n\e[0;90m"
        exit 1
      fi
    fi
    if [[ $MANUAL ]]; then
      printf "\e[1;31mPlease confirm if you've done with the changes. (yes)\n\e[0;90m"
      while true; do
        read confirm
        case $confirm in
          [Yy][Ee][Ss] ) break;;
          * ) printf "\e[1mPlease enter 'yes' to proceed. (It's not case-sensitive)\n\e[0;90m";;
        esac
      done
    fi
    generate_comment_label
    generate_comment_title
    title=$label$title
    generate_comment_body
    printf "\e[1;96mStaging the changes\n\n\e[0;90m"
    git add .
    line_break="-------------------------------------------------------"
    if [ -z "$body" ]; then
      printf "\n\e[1;96mCommiting your changes with the following message:\n$line_break\n\n\e[1;93m$title\n\e[0;90m"
      git commit -m "$title"
    else
      printf "\e[1;96mCommiting your changes with the following message and description:\n$line_break\n\n\e[38;5;69m$title\n\n\n\e[38;5;169m$body\n\e[0;90m"
      git commit -m "$title" -m "$body"
    fi
    printf "\e[1;96mPushing your commit \e[31mforcefully\e[96m into the \e[39m$BRANCH\e[96m branch of the \e[39m$REPOSITORY\e[96m repository\n\e[0;90m"
    git push --force
  fi
}

push_tag() {
  if [[ $HASH ]]; then
    git tag $TAG $HASH
  else
    git tag $TAG
  fi
  git push origin $TAG
}

update_last_commit () {
  printf "\e[1;31mNote:\e[0;39m your current branch is \e[1m$BRANCH\e[0m, are you sure to continue?(y/n)"
  read agreement
  agreement=${agreement:-y}
  if [ $agreement == y ]; then
    if $is_wd_clean ; then
      printf "\e[1;1mNothing to commit, the working directory is clean\n\e[0;90m"
    else
      # show a warning that tells the user should be caution when using this command since...
      printf "\e[1;96mStaging the changes\n\e[0;90m"
      git add .
      line_break="-------------------------------------------------------"
      printf "\n\e[1;96m$line_break\n\n"
      printf "\e[1;96mAppending your changes to the last commit of the \e[39m$BRANCH\e[96m branch in the \e[39m$REPOSITORY\e[96m repository\n\e[0;90m"
      git commit --amend --no-edit
      printf "\e[1;96mPushing your commit \e[31mforcefully\e[96m into the \e[39m$BRANCH\e[96m branch of the \e[39m$REPOSITORY\e[96m repository\n\e[0;90m"
      git push --force
    fi
  fi
}


stage_commit_push () {
  printf "\e[1;31mNote:\e[0;39m your current branch is \e[1m$BRANCH\e[0m, are you sure to continue?(y/n)"
  read agreement
  agreement=${agreement:-y}
  if [ $agreement == y ]; then
    if $is_wd_clean ; then
      printf "\e[1;1mNothing to commit, the working directory is clean\n\e[0;90m"
    elif [[ $STAGED ]] && [[ -z $(git diff --cached) ]]; then
        # Check if there are any staged changes
        printf "\e[1;91mError: No changes are staged for commit. Please stage your changes first.\e[0m\n"
        exit 1
    elif [[ ! $STAGED ]] && [[ -n $(git diff --cached) ]]; then
        # Check if there are staged changes but --staged flag is not used
        printf "\e[1;91mError: You have staged changes in your working directory.\e[0m\n"
        printf "\e[1;96mPlease either:\n"
        printf "  • Unstage all changes\n"
        printf "  • Use \e[1;93m--staged\e[1;96m flag to commit only staged changes\e[0m\n"
        exit 1
    else
      if [ $TEMPORARY ]; then
        title="TEMPORARY: This commit is temporary and will be removed afterward."
        body="This commit represents unfinished work on adding a feature or resolving a bug. The main reason for existing such commits is the user's cautiousness to avoid losing the code even though it's not ready yet."
      else
        generate_comment_label
        generate_comment_title
        title=$label$title
        generate_comment_body
      fi
      if [[ $STAGED ]]; then
        printf "\e[1;96mStashing your current unstaged changes\n\e[0;90m"
        git stash push --include-untracked --keep-index
        printf "\e[1;96mStashing your current staged changes\n\e[0;90m"
      else
        printf "\e[1;96mStashing your current changes\n\e[0;90m"
      fi
      git stash push --include-untracked
      printf "\e[1;96mPulling the latest changes of the \e[39m$BRANCH\e[96m branch\n\e[0;90m"
      git pull
      printf "\e[1;96mRestoring your stashed changes\n\e[0;90m"
      git stash pop
      printf "\e[1;96mStaging the changes\n\n\e[0;90m"
      git add .
      line_break="-------------------------------------------------------"
      if [ -z "$body" ]; then
        printf "\n\e[1;96mCommiting your changes with the following message:\n$line_break\n\n\e[1;93m$title\n\e[0;90m"
        git commit -m "$title"
      else
        printf "\e[1;96mCommiting your changes with the following message and description:\n$line_break\n\n\e[38;5;69m$title\n\n\n\e[38;5;169m$body\n\e[0;90m"
        git commit -m "$title" -m "$body"
      fi
      printf "\e[1;96mPushing your commit into the \e[39m$BRANCH\e[96m branch of the \e[39m$REPOSITORY\e[96m repository\n\e[0;90m"
      git push
      if [[ $STAGED ]]; then
        printf "\e[1;96mRestoring your stashed changes\n\e[0;90m"
        git stash pop
      fi
    fi
  fi
}

push_changes() {
  if [[ $REVISE ]] || [[ $MERGE ]]; then
    if [ $REVISE ] && [ -z "${REVISE##*[!0-9]*}" ]; then
      echo "Invalid argument: must be an integer" >&2; exit 1
    elif [ $MERGE ] && [ -z "${MERGE##*[!0-9]*}" ]; then
      echo "Invalid argument: must be an integer" >&2; exit 1
    else
      override_commits
    fi
  elif [[ $TAG ]]; then
    push_tag
  elif [[ $INITIAL ]]; then
    git push --set-upstream origin $BRANCH
  elif [[ $APPEND ]]; then
    update_last_commit
  else
    stage_commit_push
  fi
  exit 0
}
