import java.util.*;
import java.io.*;


public class jumble_solver {

    public static void main(String[] args) throws IOException {
        if(args.length < 1) {
            System.out.println("usage: java jumble_solver DICTIONARY_FILE [DICTIONARY_FILE] ...");
            System.exit(1);
        }

        HashMap<String,TreeSet<String>> sortedToOrigs = new HashMap<String,TreeSet<String>>();

        for(String dictFileName : args) {
            BufferedReader dictFileReader = new BufferedReader(new FileReader(dictFileName));
            String origWord;

            while((origWord = dictFileReader.readLine()) != null) {
                origWord = origWord.toLowerCase();
                String sortedWord = sorted(origWord);
                TreeSet<String> origs = sortedToOrigs.get(sortedWord);

                if(origs == null) {
                    origs = new TreeSet<String>();
                    sortedToOrigs.put(sortedWord, origs);
                }

                origs.add(origWord);
            }
        }

        BufferedReader stdinReader = new BufferedReader(new InputStreamReader(System.in));
        String origWord;

        System.out.print("$ ");
        System.out.flush();

        while((origWord = stdinReader.readLine()) != null) {
            origWord = origWord.toLowerCase();

            if(origWord.length() > 0) {
                String wordSorted = sorted(origWord);

                if(sortedToOrigs.containsKey(wordSorted)) {
                    TreeSet<String> anagrams = sortedToOrigs.get(wordSorted);

                    for(String word : anagrams) {
                        System.out.print(word + " ");
                    }

                    System.out.println();
                }
                else{
                    System.out.println("no anagram in dictionary");
                }
            }

            System.out.print("$ ");
            System.out.flush();
        }

        System.out.println();
    }


    public static String sorted(String str) {
        char[] letters = str.toCharArray();
        Arrays.sort(letters);
        return new String(letters);
    }
}


