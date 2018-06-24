package at.medunigraz.imi.bst.trec;

import java.io.File;
import java.util.Set;

import at.medunigraz.imi.bst.trec.experiment.Experiment;
import at.medunigraz.imi.bst.trec.experiment.ExperimentsBuilder;

public class RunnerDemo {
	public static void main(String[] args) {
		final File pmTemplate = new File(RunnerDemo.class.getResource("/templates/biomedical_articles/negative-boost-keywords.json").getFile());

		final File ctTemplate = new File(RunnerDemo.class.getResource("/templates/biomedical_articles/improved-ct.json").getFile());

		ExperimentsBuilder builder = new ExperimentsBuilder();

		builder.newExperiment().withGoldStandard(Experiment.GoldStandard.OFFICIAL_2017).withTarget(Experiment.Task.PUBMED)
				.withTemplate(pmTemplate).withWordRemoval();
		builder.newExperiment().withGoldStandard(Experiment.GoldStandard.OFFICIAL_2017)
				.withTarget(Experiment.Task.CLINICAL_TRIALS).withTemplate(ctTemplate).withWordRemoval();

		Set<Experiment> bestExperiments = builder.build();

		for (Experiment exp : bestExperiments) {
			exp.start();
			try {
				exp.join();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}

		for (Experiment exp : bestExperiments) {

		}
	}

}
