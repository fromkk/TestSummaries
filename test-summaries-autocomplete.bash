_test_summaries_complete()
{
  local tool currentWord prevWord

  tool="${COMP_WORDS[0]}"
  currentWord="${COMP_WORDS[COMP_CWORD]}"
  prevWord="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ ${currentWord} != -* ]] ; then
    COMPREPLY=( $(compgen -f "${currentWord}") )
    return 0
  fi

  COMPREPLY=( $(compgen -W "\
      --bundlePath \
      --imageScale \
      --outputPath \
      --outputType \
      --resultDirectory \
      " -- ${currentWord}))
  
  return 0
}

complete -F _test_summaries_complete test-summaries

