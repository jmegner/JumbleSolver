#include <algorithm>
#include <cctype>
#include <fstream>
#include <iostream>
#include <iterator>
#include <set>
#include <string>
#include <unordered_map>

using namespace std;


string asLowercase(const string& str)
{
    string allLower = str;
    transform(allLower.begin(), allLower.end(), allLower.begin(), tolower);
    return allLower;
}


string asSortedLowercase(const string& str)
{
    string sorted = asLowercase(str);
    sort(sorted.begin(), sorted.end());
    return sorted;
}


int main(int argc, char* argv[])
{
    if(argc < 2)
    {
        cout << "usage: jumble_solver DICT_FILE [DICT_FILE] ..." << endl;
        return 1;
    }

    unordered_map<string,set<string>> sortedToOrigs;

    for(int i = 1; i < argc; i++)
    {
        ifstream dictStream(argv[i]);
        string dictWord;

        while(getline(dictStream, dictWord))
        {
            sortedToOrigs[asSortedLowercase(dictWord)].insert(asLowercase(dictWord));
        }
    }

    string word;

    cout << "$ ";

    while(getline(cin, word))
    {
        if(word.empty())
        {
            break;
        }

        auto sortedWord = asSortedLowercase(word);

        if(sortedToOrigs.count(sortedWord) > 0)
        {
            set<string> origs = sortedToOrigs[sortedWord];

            #if 0 // if you are okay with a space after each word, including the last word
            copy(origs.begin(), origs.end(), ostream_iterator<string>(cout, " "));

            #else // else you want ", " between the words, no trailing stuff
            auto oneBeforeEnd = prev(origs.end());
            copy(origs.begin(), oneBeforeEnd, ostream_iterator<string>(cout, ", "));
            cout << *oneBeforeEnd << endl;

            #endif

        }
        else
        {
            cout << "no anagram in dictionary" << endl;
        }

        cout << "$ ";
    }

    cout << endl;

    return 0;
}

