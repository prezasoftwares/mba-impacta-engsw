package com.test.rest;


import static io.restassured.RestAssured.*;
import static org.hamcrest.Matchers.*;


import org.junit.Test;

public class AppTest 
{

    // D&D 5e API
	// http://www.dnd5eapi.co/

	@Test
	public void test_getDDClassesList_shouldReturn200AndCountFieldInRespBody() {
		when().
			get("https://www.dnd5eapi.co/api/classes").
		then().
			statusCode(200).
			assertThat().
			body("count", greaterThan(0));
	}

	@Test
	public void test_getDDChucrutePath_shouldReturn404() {
		when().
			get("https://www.dnd5eapi.co/api/chucrute").
		then().
			statusCode(404);
	}
}
