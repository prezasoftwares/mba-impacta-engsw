package com.tdd.app.domain;

public class PalindromeTool {
    public PalindromeTool() {
    }

    public boolean isPalindrome(String word) throws CustomException {
        String inverseWord = "";

        if (word == null)
            throw new CustomException("Null");

        word = word.replace(",", "").
                    replace("’", "").
                    replace(" ", "").
                    replace(".", "").
                    replace("!", "").
                    replace("/", "");
        
        for (char charactere : word.toCharArray()) {
            inverseWord = charactere + inverseWord;
        }

        return word.toLowerCase().equals(inverseWord.toLowerCase());
    }
}
