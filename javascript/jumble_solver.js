/*
author: Jacob Egner
date:   2019-07-12
repo:   https://github.com/jmegner/JumbleSolver
notes:
  using 'require' way instead of 'import' way because 'import' seems to still be experimental, see:
  https://stackoverflow.com/questions/53240278/using-node-js-require-vs-es6-import-export-2018

  readline approach from:
  https://nodejs.org/api/readline.html#readline_example_read_file_stream_line_by_line

  I could have done a fs.readFileAsync(path).toString().split('\n').forEach(...)
  but I wanted to experiment with async javascript and to not read the whole file
  into memory;

  Credit to https://stackoverflow.com/a/13654006 for use of readline for prompt
*/
'use strict';

const fs = require('fs');
const readline = require('readline');


async function processDictionaryFile(path, sortedToOrigs)
{
  try
  {
    const dictRead = readline.createInterface({
      input: fs.createReadStream(path),
      crlfDelay: Infinity
    });

    for await(let word of dictRead)
    {
      word = word.toLowerCase();
      let sortedWord = word.split('').sort().join('');

      if(!sortedToOrigs.hasOwnProperty(sortedWord))
      {
        sortedToOrigs[sortedWord] = new Set();
      }

      sortedToOrigs[sortedWord].add(word);
    }

    console.log(path + " processed");
  }
  catch (err)
  {
    console.error(err);
  }
}

(async function main()
{
  let sortedToOrigs = {};
  for(const dictPath of process.argv.slice(2))
  {
    await processDictionaryFile(dictPath, sortedToOrigs);
  }

  let stdio = readline.createInterface(process.stdin, process.stdout);
  stdio.setPrompt('$ ');
  stdio.prompt();

  stdio.on('line', word =>
  {
    if(word.length == 0)
    {
      stdio.close();
    }
    else
    {
      word = word.toLowerCase();
      let sortedWord = word.split('').sort().join('');

      if(sortedToOrigs.hasOwnProperty(sortedWord))
      {
        console.log(Array.from(sortedToOrigs[sortedWord].values()).join(' '));
      }
      else
      {
        console.log("no anagram in dictionary");
      }

      stdio.prompt();
    }
  });

})();

