package com.tdd.app.domain;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

public class PalindromeToolTest {

    private PalindromeTool palindromeTool = new PalindromeTool();

    @Test
    public void createPalindromeToolInstance(){
        assertNotNull(palindromeTool);
    }

    /*
    Estava recebendo a palavra no método setWord, porém com o desenvolvimento dos testes
    ficou evidente que seria melhor receber a palavra diretamente no método que verifica se a palavrá é palindromo.
    Com a mudança na classe de dominio, os testes dessa sessão de comentário quebraram 
    (não compilam mais, devido a exclusão do método setWord e a necessidade de receber a palavra como argumento do método de verificação (isPalindrome))

    -- deixamos aqui para fins de explicação das decisões tomadas nos demais métodos fora da area comentário

    @Test
    public void setAWordToBeCheckedInPalindromeTool_shouldGetTheSameSetValue(){
        PalindromeTool palindromeTool = new PalindromeTool();
        String wordToBeChecked = "word";

        palindromeTool.setWord(wordToBeChecked);

        assertEquals(palindromeTool.getWord(), wordToBeChecked);
    }

    @Test
    public void checkIfAnWordIsPalindrome_shouldNotBePalindrome() throws CustomException {
        PalindromeTool palindromeTool = new PalindromeTool();
        palindromeTool.setWord("NotAPalindromeWord");

        assertFalse(palindromeTool.isPalindrome());
    }

    @Test
    public void checkIfAnWordIsPalindrome_shouldBePalindrome() throws CustomException {
        PalindromeTool palindromeTool = new PalindromeTool();
        palindromeTool.setWord("tebet");

        assertTrue(palindromeTool.isPalindrome());
    }
    
    @Test
    public void checkNullInputInPalindromeTest_shouldThrowCustomException(){
        PalindromeTool palindromeTool = new PalindromeTool();
        palindromeTool.setWord(null);

        assertThrows(CustomException.class, () ->{
            palindromeTool.isPalindrome();
        });
    }
    */

    @Test
    public void testUserInputNull_shouldThrowCustomException(){
        assertThrows(CustomException.class, () -> {
            palindromeTool.isPalindrome(null);
        });
    }

    @Test
    public void testUserInputNotAPalindromeWord_shouldAssertFalse() throws CustomException{
        assertFalse(palindromeTool.isPalindrome("NotAPalindromeWord"));
    }

    @Test
    public void testUserInputARealPalindromeWord_shouldAssertTrue() throws CustomException{
        assertTrue(palindromeTool.isPalindrome("tebet"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_RotatorCase_shouldAssertTrue() throws CustomException{
        assertTrue(palindromeTool.isPalindrome("Rotator"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_bobCase_shouldAssertTrue() throws CustomException{
        assertTrue(palindromeTool.isPalindrome("bob"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_madamCase_shouldAssertTrue() throws CustomException{
        assertTrue(palindromeTool.isPalindrome("madam"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_mAlAyAlamCase_shouldAssertTrue() throws CustomException{
        assertTrue(palindromeTool.isPalindrome("mAlAyAlam"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_1Case_shouldAssertTrue() throws CustomException{
        assertTrue(palindromeTool.isPalindrome("1"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_AblewasIereIsawElbaCase_shouldAssertTrue() throws CustomException{
        assertTrue(palindromeTool.isPalindrome("Able was I, ere I saw Elba"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_MadamCase_shouldAssertTrue() throws CustomException{
        assertTrue(palindromeTool.isPalindrome("Madam I’m Adam"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_StepOnNoPetsCase_shouldAssertTrue() throws CustomException{
        assertTrue(palindromeTool.isPalindrome("Step on no pets."));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_TopspotCase_shouldAssertTrue() throws CustomException{
        assertTrue(palindromeTool.isPalindrome("Top spot!"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_02022020Case_shouldAssertTrue() throws CustomException{
        assertTrue(palindromeTool.isPalindrome("02/02/2020"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_xyzCase_shouldAssertFalse() throws CustomException{
        assertFalse(palindromeTool.isPalindrome("xyz"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_elephantCase_shouldAssertFalse() throws CustomException{
        assertFalse(palindromeTool.isPalindrome("elephant"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_CountryCase_shouldAssertFalse() throws CustomException{
        assertFalse(palindromeTool.isPalindrome("Country"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_ToppostCase_shouldAssertFalse() throws CustomException{
        assertFalse(palindromeTool.isPalindrome("Top . post!"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_WonderfulfoolCase_shouldAssertFalse() throws CustomException{
        assertFalse(palindromeTool.isPalindrome("Wonderful-fool"));
    }

    @Test
    public void testUserAcceptanceCriteriaFor_WildimaginationCase_shouldAssertFalse() throws CustomException{
        assertFalse(palindromeTool.isPalindrome("Wild imagination!"));
    }
}
