# == Schema Information
#
# Table name: project_answers
#
#  id                  :integer          not null, primary key
#  project_id          :integer
#  project_question_id :integer
#  answer              :text
#  created_at          :datetime
#  updated_at          :datetime
#
# Indexes
#
#  index_project_answers_on_project_id           (project_id)
#  index_project_answers_on_project_question_id  (project_question_id)
#

describe ProjectAnswer do
  context 'associations' do
    it 'belongs to a project' do
      t = ProjectAnswer.reflect_on_association(:project)
      expect(t.macro).to eq(:belongs_to)
    end

    it 'belongs to a question' do
      t = ProjectAnswer.reflect_on_association(:project_question)
      expect(t.macro).to eq(:belongs_to)
    end
  end

  context 'validations' do
    it 'must have a project question' do
      pa = build :project_answer, project_question_id: nil
      expect(pa.save).to eq(false)
      expect(pa.errors.keys.include?(:project_question)).to eq(true)
    end

    it 'must have valid project question id' do
      pa = build :project_answer, project_question_id: 9999
      expect(pa.save).to eq(false)
      expect(pa.errors.keys.include?(:project_question)).to eq(true)
    end
  end
end
