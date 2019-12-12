#include <iostream>
#include <fstream>
#include <string>
#include <map>
#include <set>
#include <algorithm>
#include <cctype>

using namespace std;


int main(int argc, char **argv) {
    if(argc < 2) {
        cout << "usage: jumble_solver DICT_FILE [DICT_FILE] ..." << endl;
        return 1;
    }

    map<string,set<string> > sortedToOrigs;

    for(int i = 1; i < argc; i++) {
        ifstream dictStream(argv[i]);
        string dictWord;

        while(getline(dictStream, dictWord)) {
            transform(dictWord.begin(), dictWord.end(), dictWord.begin(),
                (int(*)(int)) tolower);

            string sortedWord = dictWord;
            sort(sortedWord.begin(), sortedWord.end());
            sortedToOrigs[sortedWord].insert(dictWord);
        }
    }

    string word;

    cout << "$ ";

    while(getline(cin, word)) {
        transform(word.begin(), word.end(), word.begin(),
            (int(*)(int)) tolower);

        sort(word.begin(), word.end());

        if(sortedToOrigs.count(word) > 0) {
            set<string> origs = sortedToOrigs[word];

            for(set<string>::iterator itr = origs.begin();
                itr != origs.end();
                itr++)
            {
                cout << *itr << " ";
            }

            cout << endl;
        }
        else {
            cout << "no anagram in dictionary" << endl;
        }

        cout << "$ ";
    }

    cout << endl;

    return 0;
}

