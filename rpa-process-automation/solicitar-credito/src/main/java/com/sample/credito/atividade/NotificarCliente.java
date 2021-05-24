package com.sample.credito.atividade;

import org.camunda.bpm.engine.delegate.DelegateExecution;
import org.camunda.bpm.engine.delegate.JavaDelegate;

public class NotificarCliente  implements JavaDelegate{

	@Override
	public void execute(DelegateExecution execution) throws Exception {
		System.out.println("####################################");
		System.out.println("Processo Finalizado");
		System.out.println("####################################");
	
		String nome = (String) execution.getVariableLocal("nome");
		Boolean aprovado = (Boolean) execution.getVariableLocal("aprovado");
		
		if(aprovado) {
			System.out.println("Parabéns Sr(a) " + nome + " seu crédito foi aprovado");
		} else {
			System.out.println("No momento não foi possivel atender a sua solicitação Sr(a) " + nome);
		}

	}
	
}