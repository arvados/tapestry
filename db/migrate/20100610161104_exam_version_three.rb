class ExamVersionThree < ActiveRecord::Migration
  def self.up

    v2 = ExamVersion.find_by_title_and_version('Risks and Benefits',2)
    v2.published = false
    v2.save!
    e = v2.duplicate!
    q = e.exam_questions.find_by_ordinal(1)
    q.answer_options = []
    q.answer_options << AnswerOption.new(:answer => '(a) Loss of employment or employability', :correct => true)
    q.answer_options << AnswerOption.new(:answer => '(b) Synthetic DNA identical to yours could be made and planted at a crime scene', :correct => true)
    q.answer_options << AnswerOption.new(:answer => '(c) Inferences of your paternity or genealogy', :correct => true)
    q.answer_options << AnswerOption.new(:answer => '(d) Claims about your propensity for traits or diseases (including diseases without cures or treatments)', :correct => true)
    q.answer_options << AnswerOption.new(:answer => '(e) Potential financial costs of medical care, such as seeking diagnostic tests or medical advice, motivated by participation in this project', :correct => true)
    q.answer_options << AnswerOption.new(:answer => '(f) Not all potential risks of participation are known', :correct => true)
    q.save!

    q = e.exam_questions.find_by_ordinal(5)
    q.question = 'True or False: If you request to have your data removed from the study after your data are posted on the internet or shared with the research community, it is possible to ensure that your data will be fully removed from all research (PGP and/or third party) and from the public domain. (choose the best answer)'
    q.save!

    q = ExamQuestion.new(:kind => "MULTIPLE_CHOICE", :ordinal => 8, :question => 'True or false:  It is possible that someone could use your DNA or cells to falsely implicate you in improper activities or pursue unexpected reproductive uses of your cells including production of human clones.')
    q.answer_options << AnswerOption.new(:exam_question_id => q.id, :answer => 'True', :correct => true)
    q.answer_options << AnswerOption.new(:exam_question_id => q.id, :answer => 'False', :correct => false)
    q.save!
    e.exam_questions << q

    q = ExamQuestion.new(:kind => "MULTIPLE_CHOICE", :ordinal => 9, :question => 'All of the following statements are TRUE except one.  (choose the statement that is FALSE)')
    q.answer_options << AnswerOption.new(:exam_question_id => q.id, :answer => '(a) By participating in this study I can expect to find that I am a carrier for several recessive genetic disorders which may lead me to seek confirmatory testing for myself and genetic carrier testing of my partner, future partners, and family members for assessment of reproductive risk and family planning.', :correct => false)
    q.answer_options << AnswerOption.new(:exam_question_id => q.id, :answer => '(b) In general, when two partners are carriers for the same recessive genetic disorder,  the risk of being affected for each pregnancy is 25%.', :correct => false)
    q.answer_options << AnswerOption.new(:exam_question_id => q.id, :answer => '(c) No results from the PGP, including carrier status, should be used for medical decision making unless results are verified with repeat clinical sequencing through consultation with a health care professional.', :correct => false)
    q.answer_options << AnswerOption.new(:exam_question_id => q.id, :answer => '(d) Follow up medical costs for myself, my partner, or family members, resulting from participation in the PGP are not covered by the PGP and may not be covered by my health insurance provider.', :correct => false)
    q.answer_options << AnswerOption.new(:exam_question_id => q.id, :answer => '(e) Healthy participants with no significant family history of disease are unlikely to find they are carriers for any genetic disorder.', :correct => true)
    q.save!
    e.exam_questions << q

    e.published = true
    e.save!


    v2 = ExamVersion.find_by_title_and_version('Transmission',2)
    v2.published = false
    v2.save!
    e = v2.duplicate!
    e.exam_questions = [ e.exam_questions.find_by_ordinal(4), e.exam_questions.find_by_ordinal(5) ]
    e.published = true
    e.save!
    q = e.exam_questions.find_by_ordinal(4)
    q.ordinal = 1 
    q.save!
    q = e.exam_questions.find_by_ordinal(5)
    q.ordinal = 2
    q.save!

    v2 = ExamVersion.find_by_title_and_version('Gene Expression',1)
    v2.published = false
    v2.save!
    
    ge = v2.duplicate!
    ge.title = 'Gene Expression and Regulation'

    v2 = ExamVersion.find_by_title_and_version('Gene Regulation',2)
    v2.published = false
    v2.save!

    gr = v2.duplicate!

    tmp1 = ge.exam_questions.find_by_ordinal(4)
    tmp1.ordinal = 3
    tmp1.save

    tmp2 = gr.exam_questions.find_by_ordinal(3)
    tmp2.ordinal = 4

    ge.exam_questions = [ ge.exam_questions.find_by_ordinal(1), ge.exam_questions.find_by_ordinal(2), tmp1, tmp2 ]
    ge.published = true
    ge.save!
    gr.destroy
    
    v2 = ExamVersion.find_by_title_and_version('Genetics & Society',1)
    v2.published = false
    v2.save!
    e = v2.duplicate!

    tmp = e.exam_questions.find_by_ordinal(4)
    tmp.ordinal = 3

    e.exam_questions = [ e.exam_questions.find_by_ordinal(1), e.exam_questions.find_by_ordinal(2), tmp ]
    e.published = true
    e.save!

  end

  def self.down

    ExamVersion.find_by_title_and_version('Risks and Benefits',3).destroy
    v2 = ExamVersion.find_by_title_and_version('Risks and Benefits',2)
    v2.published = true
    v2.save!

    ExamVersion.find_by_title_and_version('Transmission',3).destroy
    v2 = ExamVersion.find_by_title_and_version('Transmission',2)
    v2.published = true
    v2.save!

    ExamVersion.find_by_title_and_version('Gene Expression and Regulation',2).destroy
    v2 = ExamVersion.find_by_title_and_version('Gene Expression',1)
    v2.published = true
    v2.save!
    v2 = ExamVersion.find_by_title_and_version('Gene Regulation',2)
    v2.published = true
    v2.save!

    ExamVersion.find_by_title_and_version('Genetics & Society',2).destroy
    v2 = ExamVersion.find_by_title_and_version('Genetics & Society',1)
    v2.published = true
    v2.save!

  end
end
