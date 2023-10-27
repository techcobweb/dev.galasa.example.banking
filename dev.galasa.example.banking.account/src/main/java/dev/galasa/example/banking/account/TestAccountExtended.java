package dev.galasa.example.banking.account;

import static org.assertj.core.api.Assertions.*;
import org.apache.commons.logging.Log;

import dev.galasa.artifact.*;
import dev.galasa.core.manager.*;
import dev.galasa.Test;

import java.nio.file.*;

/**
 * A sample galasa test class, which does slightly more than the simple test class
 */
@Test
public class TestAccountExtended {

	//obtain a reference to the logger
	@Logger
	public Log logger;

	// Allows us to access resources packaged within this bundle.
	@BundleResources
    public IBundleResources resources;

	// The run id of this test will be injected, so we can name things using it as a prefix.
	@RunName
    public String runName;
	
	// Where we can save files relating to this test if they help with diagnosing a problem.
	@StoredArtifactRoot
	public Path archivedArtifactRoot ;

	/**
	 * Test which demonstrates that the managers have been injected ok.
	 */
	@Test
	public void simpleSampleTest() {
		assertThat(logger).isNotNull();
		assertThat(resources).isNotNull();
		assertThat(runName).isNotNull();
		assertThat(runName.trim()).isNotEqualTo("");
		logger.info("All injected resources are available");
	}

	@Test
    public void testRetrieveBundleResourceFileAsStringMethod() throws Exception {
		
		// The path to the file we want to load. Relative to the src/main/resources folder.
		String resourcePathInBundle = "/textfiles/sampleText.txt";

        String textContent = resources.retrieveFileAsString(resourcePathInBundle);
		logger.info("Retrieved text file content from bundle");

        assertThat(textContent.trim()).isEqualTo("This content is read from a bundle resource file.");
    }
	
	@Test
	public void testStoreFileInResultsArchiveStore() throws Exception {

		String testMessageEmbedIntoArtifact = "Hello Galasa !";

		// Now store the artifact in the test repository.
		Path artifactFilePath = archivedArtifactRoot.resolve(runName+"-TestAccountExtended-Artifact.txt");

	    Files.write(artifactFilePath, testMessageEmbedIntoArtifact.getBytes());
	}
}
