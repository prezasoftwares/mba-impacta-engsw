package main.java.com.sample.credito.atividade;

import org.camunda.bpm.engine.delegate.DelegateExecution;
import org.camunda.bpm.engine.delegate.JavaDelegate;

public class LiberarCredito implements JavaDelegate{

	@Override
	public void execute(DelegateExecution execution) throws Exception {

		String nome = (String) execution.getVariableLocal("nome");
		
		System.out.println("Analise Automatica realizada para Sr(a) " + nome);
	
	}
	
}