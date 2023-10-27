package dev.galasa.example.banking.payee;

import static org.assertj.core.api.Assertions.*;

import dev.galasa.core.manager.*;
import dev.galasa.Test;

/**
 * A sample galasa test class 
 */
@Test
public class TestPayee {

	// Galasa will inject an instance of the core manager into the following field
	@CoreManager
	public ICoreManager core;

	/**
	 * Test which demonstrates that the managers have been injected ok.
	 */
	@Test
	public void simpleSampleTest() {
		assertThat(core).isNotNull();
	}

}
