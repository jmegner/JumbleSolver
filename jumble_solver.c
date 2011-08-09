#include <stdio.h>
#include <stdlib.h>
#include <glib.h>
#include <string.h>
#include <ctype.h>


int charCompare(const void *a, const void *b) {
    return *(char*)a - *(char*)b;
}


int gstringCompare(gconstpointer a, gconstpointer b) {
    return strcmp(((GString*)a)->str, ((GString*)b)->str);
}


gboolean printWord(gpointer key, gpointer value, gpointer data) {
    printf("%s ", ((GString*)key)->str);
    return 0;
}


int main(int argc, char **argv) {
    size_t i, j;

    if(argc < 2) {
        printf("usage: jumble_solver_c DICT_FILE [DICT_FILE] ...\n");
        return 1;
    }

    GHashTable *sortedToOrigs = g_hash_table_new((GHashFunc)g_string_hash,
        (GEqualFunc)g_string_equal);

    for(i = 1; i < argc; i++) {
        FILE *fp;
        fp = fopen(argv[i], "r");

        if(fp) {
            char line[20];

            while(fscanf(fp, "%20s", line) == 1) {
                for(j = 0; line[j]; j++) {
                    line[j] = tolower(line[j]);
                }

                GString *origWord = g_string_new(line);
                GString *sortedWord = g_string_new(line);

                qsort(sortedWord->str, sortedWord->len,
                    sizeof(sortedWord->str[0]), charCompare);

                GTree *origWords = g_hash_table_lookup(sortedToOrigs,
                    sortedWord);

                if(!origWords) {
                    origWords = g_tree_new((GCompareFunc)gstringCompare);
                    g_hash_table_insert(sortedToOrigs, sortedWord, origWords);
                }

                g_tree_insert(origWords, origWord, 0);
            }
        }
    }

    char line[99];

    printf("$ ");

    while(scanf("%99s", line) == 1) {
        for(j = 0; line[j]; j++) {
            line[j] = tolower(line[j]);
        }

        GString *sortedWord = g_string_new(line);

        qsort(sortedWord->str, sortedWord->len,
            sizeof(sortedWord->str[0]), charCompare);

        GTree *origWords = g_hash_table_lookup(sortedToOrigs, sortedWord);

        if(origWords) {
            g_tree_foreach(origWords, (GTraverseFunc)printWord, 0);
            printf("\n");
        }
        else{
            printf("no anagram in dictionary\n");
        }

        printf("$ ");

        g_string_free(sortedWord, FALSE);
    }

    printf("\n");

    return 0;
}


