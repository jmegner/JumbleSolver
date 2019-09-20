using System;
using System.Collections.Generic;
using System.Linq;

namespace JumbleSolver
{
    class Program
    {
        static int Main(string[] args)
        {
            if(args.Length < 1)
            {
                Console.WriteLine("usage: jumble_solver DICT_FILE [DICT_FILE] ...");
                return 1;
            }

            var sortedToOrigs = new Dictionary<string, SortedSet<string>>();

            foreach (var dictFileName in args)
            {
                var fileReader = new System.IO.StreamReader(dictFileName);

                string line;
                while((line = fileReader.ReadLine()) != null)
                {
                    var origWord = line.ToLower();
                    var sortedWord = sorted(origWord);

                    SortedSet<string> origs = null;
                    if(!sortedToOrigs.TryGetValue(sortedWord, out origs))
                    {
                        origs = new SortedSet<string>();
                        sortedToOrigs.Add(sortedWord, origs);
                    }

                    origs.Add(origWord);
                }
            }

            Console.Write("$ ");

            string jumbledWord;

            while((jumbledWord = Console.ReadLine()) != null && jumbledWord.Length > 0)
            {
                jumbledWord = jumbledWord.ToLower();
                string sortedWord = sorted(jumbledWord);

                if(sortedToOrigs.ContainsKey(sortedWord))
                {
                    var origs = sortedToOrigs[sortedWord];
                    Console.WriteLine(string.Join(' ', origs));
                }
                else
                {
                    Console.WriteLine("no anagram in dictionary");
                }

                Console.Write("$ ");
            }

            return 0;
        }

        static string sorted(string str)
        {
            return new string(str.OrderBy(c => c).ToArray());
        }
    }
}
