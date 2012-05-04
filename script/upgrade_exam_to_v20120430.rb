#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

#if ARGV.size < 3 then
#	puts "Usage: #{$0} production input_filename user_id"
#	exit(1)
#end

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'


### Content Area 1: Human Subjects Research and Informed Consent

# Rename content area slightly
ca = ContentArea.where('title = ?','Human Subjects Research Literacy').first
ca.title = 'Human Subjects Research and Informed Consent'
ca.save!

# Create a new version of the exam, and mark the old version as unpublished
ev = ExamVersion.where('title = ?','Human Subjects Research Literacy').first
ev.published = false;
ev.save

ev2 = ev.duplicate!
ev2.title = 'Human Subjects Research and Informed Consent'
ev2.published = true
ev2.save

# TMP REMOVE ME
# Clear out all study guide pages
StudyGuidePage.all.each do |sgp|
  sgp.destroy
end

# Create study guide pages
sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 1
sgp.contents = <<eos
<h2>Module 1: Human Subjects Research and Informed Consent</h2>

<h3>Introduction</h3>

<p>This first module is a brief review of human subjects research and informed consent. These topics are not unique to the Personal Genome Project, but they explain why taking this enrollment exam is an important part of your participation in this project. To allow us to share genetic and health data publicly, the PGP has pioneered a new method in human subjects research called “open consent”. This consent process places a high importance on your ability to understand and consent to the risks involved in making your data and samples public.</p>
eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 2
sgp.contents = <<eos
<h3>Human subjects research and the Belmont Report</h3>

<p>Human subjects research has been a critical aspect of scientific advances in human health -- for example, drugs and other therapies must go through several rounds of testing in humans before they can be used by doctors to treat a disease.</p>

<p>Unfortunately, there have been cases where researchers have abused their relationship with research subjects. One infamous example of this is the <a href="http://en.wikipedia.org/wiki/Tuskegee_Syphilis_Study">Tuskegee Syphilis Study</a> (1932-1972), where researchers studied cases of syphilis afflicting poor black men in Tuskegee, Alabama. These men believed they were receiving free health care from the US government -- in actuality, the researchers never treated them with penicillin (which by 1947 had become the standard treatment for syphilis) and were never informed of the disease.</p>

<p>In 1974 the United States Congress responded to these issues by establishing the National Commission for the Protection of Human Subjects of Biomedical and Behavioral Research. In 1978 this commission published the <a href="http://en.wikipedia.org/wiki/Tuskegee_Syphilis_Study">Belmont Report</a>, which guides much of current human subjects research. The Belmont Report outlines three fundamental ethical principles which should guide all human subjects research: respect for persons, beneficence, and justice.</p>

<ul>
<li><strong>Respect for persons</strong>: Individuals should be treated as autonomous agents, and persons with diminished autonomy are entitled to special protection. For individuals capable of deliberation and self-determination, this means they must be given adequate information regarding the study and that their considered opinions and choices should be respected. Some individuals are not capable of making autonomous decisions (due to youth, mental impairment, or vulnerability to exploitation) -- research studies must treat such individuals with additional protection, possibly excluding them from activities which may harm them.

The Personal Genome Project places a high importance on the autonomy of individuals and their right to take risks. Because of this, we require participants to be capable of making such a decision, and to demonstrate that they understand the risks related to participation by responding to exam questions. Individuals not capable of self-determination (due to youth or mental impairment) cannot participate in the Personal Genome Project; a caretaker or guardian cannot give consent on their behalf to participate in this study.
</li>

<li><strong>Beneficence</strong>: A study should maximize potential benefits and minimize potential harm for its participants. It is sometimes the case, however, that the subjects themselves are unlikely to benefit from a study -- for example, they may have an incurable condition the researchers seek to prevent. Thus, beneficence can also represent a benefit to a group of individuals that those subjects represent, rather than the subjects themselves. Sometimes this leads to ambiguous situations where subjects are exposed to risks with little chance of benefit, in the hopes of benefiting others -- the appropriateness of such studies depends on the risks and benefits involved, and on the autonomy of the subjects who decide to participate. Ethics commissions (notably Institutional Review Boards) must weigh the risks and benefits when giving approval to studies. During the course of a study, Data Safety Monitoring Boards watch over the safety and well-being of the participants.

Although there are some instances where whole genome data has benefited individuals, the Personal Genome Project believes these will be (at least at first) exceptional cases. In particular, the public release of genome data involves numerous risks and is unlikely to provide any immediate benefit to participants. However, creating such a public data set is vital for researchers and clinicians to learn how to use human genome data and use it to improve human health. As such, participation in the Personal Genome Project is best seen as a benefit to humanity as a whole, rather than to the participant themselves.</li>

<li><strong>Justice</strong>: Who should benefit from a study, and who should bear the burden of risk? Fairness in distribution of benefits and risks means that research studies should not be exploitative. Particular groups should not suffer an undue burden of risks simply because they are more readily available or vulnerable to pressure, and groups which take risks should also represent groups which are likely to benefit from the research.

Participants in the Personal Genome Project have so far been a self-selecting group who have learned about our project through word-of-mouth or articles which mention the project. While we plan to extend our recruitment to individuals with specific diseases, we do so in the hope that better understanding and treatments for those diseases may arise from such study. We also hope to extend our recruitment to older individuals, who are able to share a lifetime of health information -- many older people are highly motivated to contribute to a better understanding of health and aging.</li>

</ul>
eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 3
sgp.contents = <<eos
<h3>What is informed consent?</h3>

<p>Informed consent is a process whereby individuals assess their willingness to voluntarily participate in a research project, based on their understanding of the purpose of the project. Presenting individuals with information regarding the risks and benefits of a study is necessary for their decision to participate, and it is important that this information is conveyed in a manner that fosters comprehension.</p>

<p>These study sections and exam questions are intended to ensure that you are presented with the information you need to make an informed decision regarding participation in the Personal Genome Project. However, the informed consent process shouldn't be just a one-time event. It should be an ongoing discourse that lets an individual assess whether to participate, before the research begins, and whether to continue to participate as the research progresses.</p>

<h3>What is open consent?</h3>

<p>"Open consent" is a type of informed consent developed in response to the highly personal and re-identifiable nature of genome research. Genome data is both sensitive information and difficult to make anonymous: it uniquely identifies an individual, and it has the potential to predict a variety of personal traits and medical conditions.</p>

<p>Traditionally human subjects research has made assurances regarding the confidentiality of data, as data was “anonymized” to protect privacy. In genomic studies participant data can be protected, but privacy and anonymity cannot be guaranteed. Even if precautions are taken, data security can be breached in many ways and assurances of anonymity are an over-promise.</p>

<p>Thus, participants in the Personal Genome Project are explicitly not promised anonymity. Our project recognizes that the public release of personal data and samples will expose participants to the risk of re-identification, and to other open-ended risks associated with the unrestricted sharing of data and samples.</p>

<p>Not all risks are known. This enrollment exam and the full consent form discuss some of the risks involved with participation -- including many hypothetical scenarios -- but there may be other risks we have not anticipated.</p>

eos
sgp.save

# Move this question to position 3; reword slightly; delete fifth option; reword fourth (correct) option.
eq = ev2.exam_questions.where('question = ?','Which of the following best defines the “informed consent process”? (choose the best answer)').first
eq.ordinal = 3
eq.question = 'Which of the following best describes "informed consent"?'
eq.save

ao = eq.answer_options.where('answer = ?','(d) A process permitting the subject to assess whether to participate, before a study starts, and revisited as needed to reassess willingness to continue.').first
ao.answer = '(d) A discourse permitting the subject to assess whether to participate, before a study starts, and revisited as needed to reassess willingness to continue.'
ao.save

ao = eq.answer_options.where('answer = ?','(e) c and d are correct.').first
ao.destroy!

# Move this question to position 1; reword slightly.
eq = ev2.exam_questions.where('question = ?','What are the ethical principles espoused in the Belmont Report? (choose the best answer)').first
eq.ordinal = 1
eq.question = 'What are the three ethical principles espoused in the Belmont Report?'
eq.save

# Insert new question at position 2
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'Participation in the Personal Genome Project is likely to directly benefit participants.'
eq.ordinal = 2
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = 'True'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = 'False'
ao.correct = 1
ao.save

# Insert new question at position 4
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'Which of the following best describes "open consent"?'
eq.ordinal = 4
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) A consent process where participants acknowledge the risk of privacy loss associated with the collection of genome and other re-identifiable data.'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) A consent process which requires participants to publicly reveal their name and other identifying data.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) A consent process where participants agree to permanent participation in a research project and may not withdraw.'
ao.correct = 0
ao.save

### Content Area 2: Genetic Concepts

# Rename content area, and put it in position 2
ca = ContentArea.where('title = ?','Genetic Literacy').first
ca.title = 'Genetic Concepts'
ca.ordinal = 2
ca.save!

# Create a new version of the first exam, and mark the old version as unpublished
ev = ExamVersion.where('title = ?','Nature of Genetic Material').first
ev.published = false;
ev.save

ev2 = ev.duplicate!
ev2.title = 'Genetic Concepts'
ev2.published = true
ev2.save

# Create study guide pages
sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 1
sgp.contents = <<eos
<h2>Module 2: Genetic Concepts</h2>

<p>We don’t require expert knowledge in genetics to join the Personal Genome Project, but knowing a bit about the subject is important because it provides a context for understanding the type of data you will be receiving and making public. Genomes and DNA in particular are often regarded by many as powerful and mysterious -- after all, they are core parts of what make us who we are.</p>

<p>We hope to demystify the subject a bit by covering some topics we think are important for participants. And a quick note to the genetics experts in the audience: We know this brief review makes many simplifications, biology is a science full of exceptions. Sometimes we sacrifice technical accuracy for the sake of clarity and understanding.</p>

eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 2
sgp.contents = <<eos
<h3>DNA is the molecule of information</h3>

<p>Deoxyribonucleic acid (DNA) is a molecule whose main purpose is carrying and copying information. The four “letters” of DNA -- A, C, G, and T -- represent the four different molecules forming links in the chain (these molecules are called nucleotides, and are named: adenosine, cytosine, guanine, and thymine). DNA is double stranded: two chains twisted around each other, zipped up as the nucleotides link together (A links with T, and C links with G). DNA can be copied by separating those two strands and creating a new partner.</p>

<p>DNA’s instructions are used to create proteins, and these proteins are what carry out the various tasks need for cells and bodies to live. The translation of DNA to create proteins is called the “genetic code”,  and a section of DNA coding for a protein is called a “gene”. Changes to DNA might change the way a protein functions (sometimes completely breaking it), or it might change how strongly the gene is “expressed” (in other words, how many copies of that protein it produces).</p>

eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 3
sgp.contents = <<eos
<h3>How do DNA instructions create a person?</h3>

<p>How does this all come together to build a person? You can imagine how it may be similar to instructions for making a house. It might read something like this:</p>
<ul>
<li>Using part 385 (a saw), cut a 10 foot long 2x4 out of pine, call this “part 16552”.</li>
<li>Place the end of part 16552 perpendicular to the midpoint of part 3550 (a 20 foot 2x4)</li>
<li>Use part 366 (a screwdriver) to insert four copies of part 6080 (screws) through part 3550 and part 16552.</li>
</ul>
<p>Each of these parts could be thought of as proteins: some of them form structural elements, others interact to attach and modify the parts. That’s not all -- proteins are also reading the instructions, finding and using other genes to make new proteins. </p>

<p>In total there are around 23,000 genes that create proteins. When a sperm from the father fertilizes an egg from the mother, each contributes one half of the genome of the conceived child. This fertilized egg divides repeatedly along with its genome giving rise to all of the cells of that individual. Thus, all of the cells in your body carry a copy of your genome. What makes each cell of your body different is that they follow different instructions: a neuron has one set of active genes, a skin cell has a different set. Unlike the instructions you might have written, your genome isn’t in order -- the first instruction might be on page 680, the second on page 23, and the third on page 1,550!</p>

<p>Just as there is no single instruction “build a bedroom”, there is no single instruction in the genome to “build a hand”. Instead each gene is specifying a part of the whole. Over thousands of generations and across a population of billions of people, imperfections in the copying process and other environmental factors have introduced small changes in our genomes that make all of us unique and different from one another - even slightly different from our parents. Sometimes a change to these instructions has a drastic effect -- perhaps none of the windows have glass, because the “glass” part is broken! Other times the effect is subtle and normal -- for example, if the windows in your bedrooms were all built to be 2 inches wider. We refer to these differences -- both drastic and subtle -- as “genetic variations” or “variants”. (We prefer to use the more neutral term “variant” instead of “mutation” because the effects of many variants are unclear.)</p>

<p>Not all changes to DNA affect the instructions. In fact, very few changes do, because most changes to DNA occur outside of protein-coding regions. Genes are scattered throughout the genome: the parts that specify protein account for only 1% of the DNA. (If your genome were a book, the publisher is terribly wasteful of paper!) As a result, most changes to DNA have no effect on your traits -- but they are inherited nevertheless and provide a unique pattern that can be used to understand ancestry.</p>

eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 4
sgp.contents = <<eos
<h3>Nature versus Nuture</h3>

<p>Genes are not destiny -- while all these proteins are working hard to create a person, a lot of what you are is influenced by the environment. This dichotomy is often expressed as “nature versus nurture”: the DNA is the “nature” (your apparent destiny) while the environment surrounding you is the “nurture” (the things outside the DNA that influence how you grow and change). The truth is that it is all an interaction: your genes are working together with their environment to produce a person.</p>

<p>This means that not all genetic variations predict absolute consequences, and their effects often depend on your personal history. For example, there is a genetic variation that predicts an increased risk of emphysema for people who smoke -- if you never smoked, then the effect of this variation is never seen. The environment you experience throughout your life influences the consequences of genetic variations.</p>

<p>Your “environment” starts early in life -- before you are born! From the moment of fertilization, there are variations in what people experience during their fetal development. Other variations in people could simply be random: a cell just happened to move to the left or right, in these early stages of embryonic development. What does this mean? Not all immutable traits are necessarily genetic. Some congenital aspects of ourselves (things we were born with) could instead be more related to random chance, or the very early environments. Who we are is a mixture of genetics, environment, and chance.</p>

eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 5
sgp.contents = <<eos
<h3>One copy from each parent</h3>

<p>One last technical detail that is important for you to know about is that, for most genes, you have inherited two copies -- one from your mother’s genome, one from your father’s genome. Generally this works quite well, because you have a “back up”: one of the genes might be defective, but the other one works fine -- you’ll never notice any problem.</p>

<p>As a result, for many traits and diseases someone is only affected if they receive two broken copies of a gene -- one from each parent. These traits and diseases are called “recessive” because they “recede” in the presence of a working version of the gene. The parents of the affected individual could be totally unaffected if they only have one broken copy each (they are “carriers” of the genetic variation), and their chances of a child being affected is 25%. This is because there is an equal chance that each parent will pass on either the good copy or the broken copy (it’s like flipping a coin twice: both of them got “tails” and passed their broken version of the gene to the child).</p>

<p>There are other traits and diseases where the genetic variation causes an effect even when seen only once … it might even create an additional function -- instead of a broken screwdriver imagine one that keeps trying to use nails as well as screws, destroying many nails in the process! A person only needs one copy of such a variation for it to have an effect. In this case the variant is called “dominant” because its qualities “dominate” regardless of the other copy. When a parent has a single copy of a variant, their child has a 50% chance of inheriting it.</p>

<p>Finally, many variations may have intermediate effects -- one copy has a little effect, two copies have a larger effect. Others only have an effect when the person *also* has a different, additional variation. When looking at some traits, all of these intermediate effects can overlap in a complicated way -- many common human traits (like height and skin color) are called “multigenic” because they are affected by genetic variations in many different genes.</p>

<p>In summary, just because someone carries a variation associated with a disease doesn’t mean that they will have the disease, or even that they have an increased risk. It depends on how strong the variant’s predicted effect is, how that effect interacts with the environment, and whether that effect is recessive, dominant, or something more complicated. It is also important to remember that our understanding of genetic variation is far from complete -- scientific literature can sometimes be mistaken regarding the true impact of a genetic variation.</p>
eos
sgp.save

# Remove old questions
ev2.exam_questions.where('ordinal != 2').each do |eq|
  eq.destroy
end

# Move this question to position 1; reword.
eq = ev2.exam_questions.where('question = ?','An individual is found to have an inherited mutation in a gene associated with breast cancer. In which cells is this form of the gene located? (choose the best answer)').first
eq.ordinal = 1
eq.question = 'An individual is found to have an inherited genetic variation associated with increased susceptibility to asthma. In which cells is this genetic variation located? (choose the best answer)'
eq.save

# Update answer options
ao = eq.answer_options.where('answer = ?','(e) All the cells of the individual.').first
ao.answer = '(a) All the cells of the individual.'
ao.save

eq.answer_options.where('answer != ?','(a) All the cells of the individual.').each do |ao|
  ao.destroy!
end

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) Only in cells of the lungs.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) Only in the cells of the lungs and reproductive tissues (ovaries or testes).'
ao.correct = 0
ao.save

# Insert new question at position 2
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'Which of the following is a characteristic of genetic variations in DNA? (choose the best answer)'
eq.ordinal = 2
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) Most variations negatively impact the health of the individual.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) Most variations have have no discernible effect.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = "(c) Variants are inherited and can be used to understand an individual’s ancestry."
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(d) answer (a) and (c)'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(e) answer (b) and (c)'
ao.correct = 1
ao.save

# Insert new question at position 3
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'Your muscle cells, nerve cells, and skin cells have different functions because: (choose the best answer)'
eq.ordinal = 3
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) each kind of cell has a different set of genetic variations within its genes.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) each kind of cell has a different set of active genes.'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) each kind of cell contains different subsets of genes in its DNA.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(d) these cells are descended from muscle, nerve, and skin cells inherited from your parents.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(e) answers (c) and (d)'
ao.correct = 0
ao.save

# Insert new question at position 4
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'Cystic fibrosis is a recessive disorder caused by variants creating broken versions of the CFTR gene: an individual must have both of their CFTR genes broken to develop the disease. Imagine two healthy parents, both carrying one broken copy of CFTR. What is the probability that a child of these two parents will be affected with CF? (choose the best answer)'
eq.ordinal = 4
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) 0%'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) 25%'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) 50%'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(d) 75%'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(e) 100%'
ao.correct = 0
ao.save

# Copy a question from the old 'Gene Expression and Regulation' exam, and put it in position 5
eq = ExamQuestion.where('question like ?',"At what times during an individual%s life does the environment influence the expression of his or her genes? (choose the best answer)").first.clone
eq.ordinal = 5
eq.exam_version = ev2
eq.save

# Update answer options
ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) Environment has little or no effect on how genes are expressed.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) From conception and lasting throughout life.'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) After birth and lasting throughout life.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(d) From conception and lasting until puberty is ended.'
ao.correct = 0
ao.save

# Insert new question at position 6
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'If an individual has a test for a genetic variation associated with a particular disease, and the result shows the individual has this variant, what will that mean? (choose the best answer)'
eq.ordinal = 6
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = "(a) The individual will definitely develop the disease if it's a dominant effect."
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = "(b) The individual will only develop the disease if their parent also had it."
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = "(c) It depends upon the variant involved -- how strong the variant’s effect is, how it interacts with the environment, and whether that effect is dominant or recessive or something more complicated."
ao.correct = 1
ao.save

# Unpublish old exams

ev = ExamVersion.where("title = ? and published = ?",'Transmission',true).first
ev.published = false
ev.save

ev = ExamVersion.where("title = ? and published = ?",'Genetics & Society',true).first
ev.published = false
ev.save

ev = ExamVersion.where('title = ? and published = ?','Gene Expression and Regulation',true).first
ev.published = false
ev.save

### Content Area 3: PGP Protocols Literacy

# Change ordinal to 3
ca = ContentArea.where('title = ?','PGP Protocols Literacy').first
ca.ordinal = 3
ca.save!

#### Exam 3: PGP Enrollment Procedures

#Unpublish old exam
ev = ExamVersion.where("title = ? and published = ?",'Risks and Benefits',true).first
ev.published = false
ev.save


# Create a new version of the exam, and mark the old version as unpublished
ev = ExamVersion.where('title = ?','Enrollment Procedures').first
ev.published = false;
ev.save

ev2 = ev.duplicate!
ev2.title = 'PGP Enrollment Procedures'
ev2.published = true
ev2.save

# Create study guide pages
sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 1
sgp.contents = <<eos
<h2>Module 3: PGP Enrollment Procedures</h2>

<h3>Introduction</h3>

<p>The Personal Genome Project (PGP) seeks to publicly share genome data combined with public health and trait information. This module describes the procedures involved regarding your enrollment in the project.</p>

<p>In addition to exposing yourself to various risks, you will also expose your relatives to many of these same risks because they share DNA with you. Participation is ultimately your decision, but we strongly recommend you discuss participation in the PGP with your relatives before you submit your enrollment application (and on an ongoing basis throughout your participation).</p>

eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 2
sgp.contents = <<eos
<h3>PGP enrollment steps</h3>
<p>The steps of PGP enrollment are as follows:</p>
<table class="admin_table">
<tr>
<th width="300"><strong>(1) Mini-consent and account creation</th></strong>
<td>
<p>You have already performed this step. This small consent form allows us to ask you questions regarding your eligibility, and some other demographic and trait information. Personally identifying information provided here is considered private.</p>

<p>You should have signed this form electronically with your name and email.</p>

<p>You may not sign this consent for another individual nor perform later enrollment steps for another individual, even if you have legal authority to make health care decisions on their behalf (e.g. a guardian). The decision to enroll must be made by individuals capable of giving their own consent.</p>
</td>
</tr>
<tr>
<th>
<strong>(2) Email address verification</strong>
</th>
<td>
Your email address was verified in this step. Your email is a critical aspect of your account: resetting your password will send a new password to your email account. Anyone who has access to this email address will be able to access to your personal PGP data and could pretend to be you.
</td>
</tr>
<tr>
<th>
<strong>(3) Eligibility screening</strong>
</th>
<td>
A small set of questions to see if you meet our eligibility requirements.
</td>
</tr>
<tr>
<th>
<strong>(4) Enrollment exam</strong>
</th>
<td>
This enrollment exam was created to ensure that you are informed of the risks and benefits of participation in the PGP.
</td>
</tr>
<tr>
<th>
<strong>(5) Full consent form</strong>
</th>
<td>
After passing the entrance exam, you will be presented with the full consent form. We encourage you to read it carefully -- signing this form means that you agree to the protocols and risks associated with the PGP.
</td>
</tr>
<tr>
<th>
<strong>(6) Designate proxies and enter initial data</strong>
</th>
<td>
As your account starts, we ask for some initial data. One particularly important piece of information we ask you for is who you designate as proxies: people who should act in your stead to make decisions regarding your participation in the PGP, should you die or become mentally impaired. The identities of these proxies will be considered private information.
</td>
</tr>
<tr>
<th>
<strong>(7) Submit enrollment application</strong>
</th>
<td>
Generally all individuals who pass these steps and submit an application become enrolled in the PGP.
</td>
</tr>
<tr>
<th>
<strong>(8) Active enrollment</strong>
</th>
<td>
Enrollment should occur within 1-2 months of submitting your application; you should receive an email notification. Once enrolled, you will be able to log in as an active participant and perform associated activities on the website (including addition of data to your public profile and signing up for sample collections).
</td>
</tr>
</table>

<p>Remember that your participation is always voluntary. You may withdraw at any time, for any reason.</p>

<p>In addition, the PGP may decide to end your participation at any time, whether or not you agree to such a termination. Some reasons this may occur include: if we have reason to believe a participant misrepresented their identity, if we believe a participant was enrolled by someone else (i.e. not autonomously), or if we suspect a participant is likely to submit samples or data belonging to other individuals.</p>
eos
sgp.save

eq = ev2.exam_questions.where('question = ?','True or False: In order to enroll in the PGP individuals may need to travel to a designated medical center where a trained health professional will collect tissue samples including skin or blood. (choose the best answer)').first
eq.destroy

# Insert new question at position 1
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'Enrollment can be performed either by the individual applicant, or by another individual that has legal authority to make health care decisions for the applicant.'
eq.ordinal = 1
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = 'True'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = 'False'
ao.correct = 1
ao.save

# Move this question to position 2.
eq = ev2.exam_questions.where('question = ?','Your participation in the Personal Genome Project is: (choose the best answer)').first
eq.ordinal = 2
eq.save

# Update answer options
ao = eq.answer_options.where('answer = ?','(b) Voluntary').first
ao.answer = '(a) Always voluntary'
ao.save

ao = eq.answer_options.where('answer = ?','(a) Required by law').first
ao.answer = '(b) Required by law after you have signed the consent form'
ao.save

ao = eq.answer_options.where('answer = ?','(c) Automatic as long as you are able to pass the entrance exam').first
ao.destroy!

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) Automatic if your data has been released publicly elsewhere'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(d) Required for certain types of health care coverage'
ao.correct = 0
ao.save

# Insert new question at position 3
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'The genetic, trait, and medical information shared publicly on the study website may have relevance to your family members. The PGP recommends that you discuss risks associated with your participation in the PGP with immediate family members: (choose the best answer)'
eq.ordinal = 3
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) Never'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) Prior to submitting your enrollment application and on an ongoing basis throughout the study'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) Only after a problem arises due to your participation in this study'
ao.correct = 0
ao.save

# Move this question to position 4
eq = ev2.exam_questions.where('question = ?','If you are enrolled, you can withdraw from the study: (choose the best answer)').first
eq.ordinal = 4
eq.save

# Update answer options
ao = eq.answer_options.where('answer = ?','(a) after you receive permission from the Principal Investigator').first
ao.answer = '(a) After you receive permission from the Principal Investigator'
ao.save

ao = eq.answer_options.where('answer = ?','(b) at any time').first
ao.answer = '(b) At any time'
ao.save

ao = eq.answer_options.where('answer = ?','(c) never').first
ao.answer = '(c) Never'
ao.save

ao = eq.answer_options.where('answer = ?','(d) after 5 years').first
ao.answer = '(d) After a 30 day waiting period'
ao.save

# Move this question to position 5
eq = ev2.exam_questions.where('question = ?','The PGP staff may decide to end your participation in this study: (choose the best answer)').first
eq.ordinal = 5
eq.question = 'The PGP staff may decide to terminate your participation in this study:'
eq.save

ao = eq.answer_options.where('answer = ?','(b) Never').first
ao.answer = '(a) Never'
ao.save

ao = eq.answer_options.where('answer = ?','(c) Only after obtaining your permission').first
ao.answer = '(b) Only after obtaining your permission'
ao.save

ao = eq.answer_options.where('answer = ?','(a) At any time').first
ao.answer = '(c) At any time'
ao.save

#### Exam 4: PGP Participation, Specimen Collection & Data Release Procedures

# Create an exam
e = Exam.new()
e.content_area = ca
e.save

ev2 = ExamVersion.new()
ev2.title = 'PGP Participation, Specimen Collection & Data Release Procedures'
ev2.published = false;
ev2.exam = e
ev2.description = '*'
ev2.ordinal = 1
ev2.save!

# Create study guide pages
sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 1
sgp.contents = <<eos
<h2>Module 4: PGP Participation, Specimen Collection & Data Release Procedures</h2>

<h3>Introduction</h3>

<p>This module describes what you can expect to occur once you are enrolled, including: how we will collect samples and data from you, how these things will be become public, and what long-term commitments you are making as a PGP participant.</p>

eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 2
sgp.contents = <<eos
<h3>Participation is an ongoing relationship</h3>

<p>Participation in the PGP is an ongoing relationship: our understanding of genomes is new, and so we are likely to revisit participants for follow-up studies, questions, and specimen recollection. By participating in the PGP you are consenting to being recontacted by us. In many cases responding to our follow-up requests is voluntary. There are two types of ongoing follow-up that is required of all participants: Quarterly Safety Reports and updates to the consent form.</p>

<p>Quarterly Safety Reports are our way of monitoring participants for adverse outcomes. Four times a year you will be emailed a reminder asking you to answer some brief questions regarding your current status, and whether you have any developments to report related to your participation in the PGP. Your responses to these reports are confidential and will be kept as private data.</p>

<p>You may also be asked to sign updates to our consent form. Because participation is ongoing, our consent document is also an ongoing process -- as the project evolves we may need to periodically revise the consent form accordingly. After a change to the consent form occurs, all participants must approve of the new consent form to be considered active participants.</p>

<p>Failure to complete quarterly safety reports or to approve the new project consent result in account deactivation (but completing the overdue report and/or reviewing and accepting the new consent will reactivate your account).</p>

<p>Ongoing participation also means you may be recontacted for various reasons, including: updates to our website, new specimen collection opportunities, and other PGP-related announcements.</p>
eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 3
sgp.contents = <<eos
<h3>Specimen collection</h3>

<p>We are pursuing a variety of methods for specimen collection, including saliva and blood collection. We may ask for you to provide your contact information (e.g. address and/or phone number), which will be kept private. Because of the resources necessary for specimen collection and processing, we may not be able to collect a specimen from you right away. Specimen collection methods should pose minimal risk to you, but will not necessarily succeed -- you may be asked to contribute a second specimen, or we might later conclude that a given collection method has yielded unusable specimens.</p>

<p>Specimen collections are always voluntary, you are not required to participate in any specimen collection events. As part of providing us with a specimen, you are consenting to an open-ended set of things which may be derived from it. Data generated from those specimens will be shared both with you and publicly. Such data could include: genome sequencing data, epigenetic data, protein and chemistry assays, and profiles of bacteria and viruses in your samples.</p>

eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 4
sgp.contents = <<eos
<h3>Release of genome data and other sample-derived data</h3>

<p>Currently, when we derive new types of data from specimens (e.g. whole genome sequencing data) we give participants a 30 day period of private access to that data. For whole genomes, in addition to raw data access we will give you our current interpretation of your data -- this interpretation is part of our research development and is extremely incomplete, it is almost certainly missing some variants and misinterpreting others.</p>

<p>We will notify you of the new data, but we will not require any approval from you to release the data -- the data will be added to your public profile 30 days after we have notified you. You may choose to withdraw from the PGP during this period and have all existing public data, specimens, and specimen-derived samples removed, in which case this private data will not be added to our public database.</p>

<p>Only new types of data will be held private for a 30 day period. For some types of data it is likely we will improve upon the data as our methods for laboratory and computational analysis improve. Updates that improve upon the quality of a given type of data may be made public immediately. For example, if we reprocess your whole genome sequencing data to correct or add information, those improvements may be made public immediately. Updates to data interpretations (e.g. genome interpretations) may also be made public immediately.</p>

<p>Remember that analyzing specimens to generate data will often take some time: whole genome sequencing currently takes months, and not all specimens can be processed immediately due to our limited resources. When possible, we will try to update you regarding the status of your specimens. We do not guarantee that the specimens you provide us will be analyzed, and even if analyzed they may fail to produce data.</p>

eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 5
sgp.contents = <<eos
<h3>Creation of cell lines</h3>

<p>For some types of specimens (include blood samples) we may derive cell lines. Cell lines are a renewing resource that is produced by growing your cells within the laboratory. Such a resource allows others to more easily access copies of your genomic material. Other groups could potentially use the cell lines to replicate or improve our sequencing results or to perform various scientific studies regarding the function of variations within your genome. Although there may be some regulations or agreements involved to acquiring cell lines, we will try to share these as freely as possible by making them available in an established repository.</p>
eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 6
sgp.contents = <<eos
<h3>Health records and other user-provided data may be immediately public</h3>

<p>Data can also be added to your profile by you, directly. This may include: addition of information regarding your health and traits, uploading of genetic data files acquired elsewhere, and making a public association of your name with your profile. All of these additions may be immediately added to your public PGP profile.</p>

<p>Health record data and other trait information is sensitive information, but it is also extremely valuable for science. Genome researchers seek to understand the connection between genetic variations and various health conditions and traits. Participants in the Personal Genome Project who share health information are especially valuable because they enable researchers to compare methods and results. We will provide you with opportunities to respond to surveys, import electronic health records, and upload various files.</p>

<p>Providing us with these data is completely voluntary. Such data can be sensitive and may greatly increase your risk of being re-identified. You should review such data carefully to ensure you are not inadvertently disclosing personal, health or insurance information you do not wish to be made public. What you make public is at your discretion, you are not required to provide us with any of these items to be a participant in the PGP.</p>
eos
sgp.save


# Insert new question at position 1
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'The only ongoing activities PGP participants must perform to be considered "active" are:'
eq.ordinal = 1
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) Yearly genome data review & Specimen recollection events'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) Yearly genome data review & Quarterly safety questionnaires'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) Quarterly safety questionnaires & Approval of updates to the consent form'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(d) Specimen recollection events & Approval of updates to the consent form'
ao.correct = 0
ao.save

# Insert new question at position 2
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'When we first produce your genome sequencing data, we will notify you and...'
eq.ordinal = 2
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) it will become public at your discretion.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) it becomes public immediately.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) the data will automatically become public in 30 days unless you withdraw from the project.'
ao.correct = 1
ao.save

# Insert new question at position 3
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'Participation in all specimen collections is required of all participants.'
eq.ordinal = 3
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) True'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) False'
ao.correct = 1
ao.save

# Insert new question at position 4
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'As a participant the following will by default become publicly accessible if derived from samples given to the PGP:'
eq.ordinal = 4
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) Genome data derived from your specimens'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) Cell lines derived from your specimens'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) Answer (a) and (b)'
ao.correct = 1
ao.save

# Now we have questions, we can publish
ev2.published = true;
ev2.save!


#### Exam 5: Potential Consequences of Receiving Personal Genome Data

# Create an exam
e = Exam.new()
e.content_area = ca
e.save

ev2 = ExamVersion.new()
ev2.title = 'Potential Consequences of Receiving Personal Genome Data'
ev2.published = false;
ev2.exam = e
ev2.description = '*'
ev2.ordinal = 2
ev2.save!

# Create study guide pages
sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 1
sgp.contents = <<eos
<h2>Module 5: Potential consequences of receiving personal genome data</h2>

<h3>Introduction</h3>

<p>Much of the data produced by the Personal Genome Project -- including whole genome data -- is produced using newly developed research techniques. Such techniques may produce erroneous results, and the interpretation of such data is in many cases ambiguous and rapidly developing. Whole genome data also has the potential to reveal much about you as a person, and this may include uncovering unexpected and potentially upsetting information.</p>

<p>We outline these risks involved here, but there may be other risks we have not yet anticipated. In particular, we plan to collect and analyze samples to produce data other than whole genome sequences (e.g. microbiome, epigenetic, or protein data). Most of the risks we discuss in this and the next module regarding your genetic data (e.g. errors in interpretation, potentially upsetting findings, potential discrimination) also apply to these other types of data.</p>
eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 2
sgp.contents = <<eos
<h3>Errors in data</h3>

<p>No test is 100% accurate, and this is especially true of data generated by research studies. Whole genome sequencing is, on the whole, an amazingly accurate technology. We estimate the chances that any given genetic variant has been called in error is less than 0.5% (1 in 200).</p>

<p>While that error rate is quite low, it’s still high enough to be troubling. This is especially true for when we find variants which are themselves quite rare in the population. If a DNA variant is only seen with 0.5% frequency, then the chances of you having the variant and the chances of an error are roughly equal. Variants with serious clinical effects also tend to be the rarest, and so often the scariest findings are also the least trustworthy.</p>

<p>Errors may occur in other ways too -- from sample mix-ups to data processing mishaps.</p>

<p>We make efforts to reduce such errors, but our research data is far from “clinical quality” and should never be considered a substitute for clinical testing. <strong>Before acting upon findings, you should always have them confirmed by a licensed healthcare professional</strong>.</p>

eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 3
sgp.contents = <<eos
<h3>Unanticipated ancestry discoveries (e.g. non-paternity)</h3>

<p>Even a small amount of genetic data is enough to make many inferences regarding a person’s ancestry. These discoveries may occur as the PGP develops tools for ancestry analysis in coming years, or they may be discovered by yourself or third parties that study the public data. </p>

<p>If this data is compared to data from relatives, you may discover that you are not related to people you thought you were related to. A common example of this is non-paternity: discovering that an individual’s father was not their biological father -- something that may be a surprise to the father, the child, and sometimes even the mother. Barring accidental sample mix-ups, such a discovery can be inevitable and is not sensitive to sequencing errors. Other examples could be discovering a similar non-paternity finding in a parent & grandparent (uncovered when your data is compared to a cousin), or discovering unknown cases of non-maternity or adoption.</p>

<p>More distant ancestry discoveries may also be discovered as your genetic data is compared to population data. For example, you may discover you have racial heritages that differ from what you had thought.</p>

eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 4
sgp.contents = <<eos
<h3>Unanticipated findings predicting serious clinical effects</h3>

<p>One negative consequence of genetic testing may be the possibility of finding out information about serious medical conditions. It may be something you can do little or nothing to prevent. It may be something rare and ambiguous, where your prognosis is very uncertain. These discoveries can lead to anxiety and stress, and they can be very difficult to anticipate.</p>

<p>Sometimes you may have reason to be concerned about a particular finding. For example, an individual whose parent has Huntington’s Disease will be concerned about discovering that they carry the same mutation, or an individual whose parents both have Alzheimers Disease might be especially concerned about their own genetic predisposition to the disease.</p>

<p>Other discoveries, however, may be totally unanticipated. This case is best illustrated by the experience of a recent PGP participant found to carry JAK2-V617F in his blood cells -- a mutation associated with causing rare and serious blood diseases. This is a mutation that probably occurred and accumulated in his blood cells during adulthood -- it was not inherited, and therefore something family history could not have predicted.</p>

eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 5
sgp.contents = <<eos
<h3>Ambiguous findings</h3>

<p>Not all genetic variants are well understood. In fact, many or most of them are quite poorly understood. Does this genetic variant really cause a disease? Is there a 100% chance? How severe will it be?</p>

<p>This is especially true of the rarest variants -- variants which may have one or two publications implying they cause a disease, but which are so rare that they have very little evidence. With so few observations it can be hard to know whether the variant really is associated with a disease and what the prognosis is.</p>

<h3>Failure to report serious findings</h3>

<p>Not all serious findings will be uncovered immediately. Some genetic variants are not successfully tested using our current genome sequencing technology. Huntington’s disease is one example of this: because of how the variant is formed in the DNA, it is very difficult for current whole genome sequencing techniques to distinguish between disease-causing and benign variants in the gene. As we improve sequencing methods we expect this variation to be discovered and reported -- but it is important to be aware that current technology has limitations.</p>

<p>In addition, many findings will be uncovered later as our ability to interpret improves. Currently our interpretations of genome data are extremely incomplete. Even as we work hard to fill in the gaps in our interpretations, the knowledge of genetic variants is constantly growing. It is very likely that serious findings will be made in your genome data long after you first received it, and after it has been made publicly available.</p>

<h3>Flaws in interpretation</h3>

<p>Finally, even if a variant is reported to have an association, there may be a flaw in our interpretation of existing literature. Such human error is inevitable when reviewing hundreds of publications and, while we hope the errors are corrected over time, new literature is always being published. In addition, the literature itself may contain errors. Our interpretations are extremely new and essentially untested. We provide them because they give some insight into how the world may view your genome data, but whole genome interpretation is a very new field of research and extremely prone to error.</p>

eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 6
sgp.contents = <<eos
<h3>Potential financial costs</h3>

<p>The results produced by the Personal Genome Project cannot be used as a medical test. Nevertheless, findings in your genome may suggest you should have clinical follow-up -- e.g. clinically-certified diagnostic testing or medical advice. As a research project, the Personal Genome Project is not able to provide you with these services and will not cover the costs. In addition, it is possible your health insurance company will not cover these costs.</p>

<p>As a result, you are potentially risking the financial burden of follow-up diagnostic testing -- even if our finding turns out to be an error in sequencing or interpretation.</p>
eos
sgp.save

# Insert new question at position 1
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'The genome data and interpretation returned to you by the PGP...'
eq.ordinal = 1
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) may contain unexpected predictions regarding your propensity for traits or diseases (including diseases without cures or treatments)'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) is accurate enough to be considered equivalent to a clinical test and medical advice.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) may fail to return important findings until long after the data is made public.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(d) answer (a) and (b)'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(e) answer (a) and (c)'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(f) all of the above'
ao.correct = 0
ao.save

# Insert new question at position 2
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'You may have medical costs if you wish to perform follow-up on one of our research findings, such as diagnostic tests and medical advice -- these are not covered by the PGP and might not be covered by your health insurance provider.'
eq.ordinal = 2
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = 'True'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = 'False'
ao.correct = 0
ao.save

# Insert new question at position 3
eq = ExamQuestion.new()
eq.kind = 'CHECK_ALL'
eq.question = 'Our genome interpretation report shows that you have a rare variant predicted to cause a serious disease. Which of the following are possible? (select all that are true)'
eq.ordinal = 3
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) The variant could be a sequencing error'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) The evidence supporting this prediction may be extremely weak'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) The prognosis for someone with this variant may be very ambiguous'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(d) The literature for this variant could have been misinterpreted'
ao.correct = 1
ao.save

# Insert new question at position 4
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'Discovery of non-paternity and other unexpected genealogy/ancestry findings... (choose the best answer)'
eq.ordinal = 4
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) are often mistaken, as they are quite sensitive to sequencing errors.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) can be avoided if participants ask to hide this information.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) may be unavoidable, as very little genetic data is required to make such discoveries.'
ao.correct = 1
ao.save

# Now we have questions, we can publish
ev2.published = true;
ev2.save!


#### Exam 6: Risks associated with making your data public

# Create an exam
e = Exam.new()
e.content_area = ca
e.save

ev2 = ExamVersion.new()
ev2.title = 'Risks associated with making your data public'
ev2.published = false;
ev2.exam = e
ev2.description = '*'
ev2.ordinal = 3
ev2.save!

# Create study guide pages
sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 1
sgp.contents = <<eos
<h2>Module 6: Risks associated with making your data public</h2>

<h3>Introduction</h3>

<p>One of the core principles of the Personal Genome Project (PGP) is that scientific material should be shared as freely as possible. This means that the PGP will make your genome data public (and any other data derived from the specimens you provide us). In addition, if participants choose to publicly share information regarding their health and traits, this information will also become publicly connected to their genome data. Finally, we will also try to share anything we derive from specimens as freely as possible (e.g. lymphocyte cell lines derived from blood samples).</p>

<p>This sharing is a great benefit to the scientific community, but it has many potential risks to our participants. We try to outline the major risks we think you are taking, but not all risks are mentioned here -- indeed, some risks may arise from future technology developments that are currently impossible to anticipate.</p>
eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 2
sgp.contents = <<eos
<h3>Loss of privacy</h3>

<p>The most obvious risk you have is that your data will become associated with your identity -- someone might, for example, figure out that genome #982 belongs to you. This risk seems so likely that many participants decide to associate their names with their genomic data at the outset (although this is not required).</p>

<p>Imagine, for example, that you wish to tell your friends about a particularly rare variant you have: only 1 in 200 people have this interesting genetic trait. From this information alone your friends might be able to figure out which genome is yours: your sex will narrow it down by a lot, your race narrows it down more, your hair color or last name might be additional clues... before you know it, they’ve figured out exactly which genome is yours! Suddenly they are able to learn many personal things about you, including everything predicted by your genome and any health record data you’ve publicly shared in your PGP profile.</p>

<p>Even if you are perfectly good at keeping secrets, your privacy could be lost as third parties become especially skilled at analyzing our data and inferring identity from it. Identities can be discovered with surprisingly little information -- for example, the combination of sex, birth date and ZIP code is specific enough to be uniquely identifying information for 87% of people! This means that some could associate your identity with your PGP data, without your knowledge and without your consent.</p>
eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 3
sgp.contents = <<eos
<h3>Discrimination on the basis of genetic or health data</h3>

<p>Politicians have been passing federal and state laws that try to protect individuals against genetic discrimination, but these protections are untested and incomplete. In 2008 Congress passed the Genetic Information Nondiscrimination Act (GINA), designed to protect individuals from the dangers of genetic discrimination. GINA prohibits health insurance companies from denying coverage or charging higher premiums solely on the basis of genetic information. GINA also prohibits employers from using genetic information for hiring, firing, promotion, and other employment decisions.</p>

<p>However, there are significant types of discrimination that GINA does not protect against. For example, GINA does not prohibit discrimination for other types of insurance (e.g. life insurance, long term care insurance, and disability insurance). In addition, as with other types of discrimination, it could be extremely difficult to prove discrimination has occurred. You might never know whether your employer found your PGP data and read about your genetic findings. GINA and similar laws are new, incomplete, and relatively untested -- you should not assume that your genetic information, if it should become associated with you, would never be used against you in a way you found objectionable, whether or not prohibited by law.</p>

<p>Finally, GINA and its state counterparts generally do not restrict the ways in which others (including employers and insurers) may use certain non-genetic data about you that may become publicly available through the PGP. Information that you share with us about your personal health and traits are extremely valuable for the scientific understanding of genomes. Unfortunately, this can also represent sensitive information (e.g., a personal or family history of mental illness). While GINA and other laws, including the Americans with Disabilities Act, prevent certain uses of certain information, you should carefully consider the information you make available and how it might be used against you or your family.</p>
eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 4
sgp.contents = <<eos
<h3>Once public, it may be impossible to completely remove your data</h3>

<p>Once we make your genetic data public, other people can download the files. In addition to analyzing that data they could choose to share those files with others, host them in their own database, or publish derivative data. You may withdraw from the PGP at any time and choose to have your public data removed from our database. However, others may already have copied this data and we cannot control what they do with it.</p>

<h3>Discovery of serious findings after data is already public</h3>

<p>As described in Module 5, our ability to interpret genomes is incomplete. It is likely that important interpretations of your genome data will be made after your data has already been made public. Potentially sensitive information may later be interpreted after the genome data has been public, and it may be too late to remove it from non-PGP databases.</p>
eos
sgp.save

sgp = StudyGuidePage.new()
sgp.exam_version = ev2
sgp.ordinal = 5
sgp.contents = <<eos
<h3>Unanticipated uses of your data and cell lines</h3>

<p>The list of potential uses of your data and cell lines by other individuals is diverse and sometimes worrisome. The benefit of these things is that other researchers will use them in their own work, greatly facilitating the process of scientific research. Other researchers might also create their own interpretations of your genetic data -- and these could make incorrect claims regarding your predisposition to traits and diseases that we cannot control. Someone might match your public data against other genetic databases to find matches for yourself or relatives -- this includes criminal and forensic DNA fingerprinting databases as well as other genetic research studies.</p>

<p>More nefarious uses are also possible, if unlikely. DNA is commonly used to identify individuals in criminal investigations. Someone could plant samples of DNA, created from genome data or cell lines, to falsely implicate you in a crime. It’s currently science fiction -- but it’s possible that someone could use your DNA or cells for in vitro fertilization to create children without your knowledge or permission, or to create human clones.</p>

<p>Not all risks are known -- there may be some risks that are impossible to anticipate at this time. It is very difficult to predict what future technologies and techniques could be applied to your DNA sequence data and cell lines.</p>
eos
sgp.save

# Insert new question at position 1
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'Which of the following best describes how your name and identity are associated with your PGP data?'
eq.ordinal = 1
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) The PGP ensures that your name can never be associated with your public PGP data.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b)  As part of participation, you are required to publicly list your name with your PGP data.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) While you are not required to publicly list your name, there is a significant risk that others may associate your name with your data, without your knowledge or consent.'
ao.correct = 1
ao.save

# Insert new question at position 2
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'Although the Genetic Information Nondiscrimination Act of 2008 protects against some types of discrimination, which of the following are still potential dangers?'
eq.ordinal = 2
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) You may suffer discrimination despite it being illegal, and this may be difficult to prove.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) You may be discriminated against when seeking some types of insurance, such as long term disability insurance or life insurance.'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) You may be discriminated against on the basis of other data you have shared (e.g. health records or other trait data)'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(d) Answers (a) and (c)'
ao.correct = 0
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(e) Answers (a), (b), and (c)'
ao.correct = 1
ao.save


# Insert new question at position 3
eq = ExamQuestion.new()
eq.kind = 'MULTIPLE_CHOICE'
eq.question = 'Although you may withdraw at any time and have your data removed from the PGP’s public database, others may have already made copies of the data and the PGP may not have any ability to prevent them from sharing it.'
eq.ordinal = 3
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) True'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) False'
ao.correct = 0
ao.save

# Insert new question at position 4
eq = ExamQuestion.new()
eq.kind = 'CHECK_ALL'
eq.question = 'What undesired things might people do with your public data and/or shared cell lines? (select all that are true)'
eq.ordinal = 4
eq.exam_version = ev2
eq.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(a) They may make inaccurate claims about your predisposition to certain traits or diseases.'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(b) Someone may find matches for you or a relative in criminal and forensic genetic databases.'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(c) Someone might use your genetic material to falsely implicate you in a crime.'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(d) It may be possible to use your material, without permission, to create children or clones'
ao.correct = 1
ao.save

ao = AnswerOption.new()
ao.exam_question = eq
ao.answer = '(e) Other risks may exist -- not all risks are known.'
ao.correct = 1
ao.save

# Now we have questions, we can publish
ev2.published = true;
ev2.save!



