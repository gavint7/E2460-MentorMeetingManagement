require 'rails_helper'

#created with help from LLM

RSpec.describe 'Mentor Meetings Management', type: :system do
  before do
    driven_by(:rack_test) # or :selenium_chrome if you're using a browser
    @mentor = create(:mentor)
    @instructor = create(:instructor)
    @team = create(:team, capacity: 5) # example capacity
    @under_capacity_team = create(:team, capacity: 2, members_count: 1)
    @meeting_date = create(:meeting_date, team: @team)
  end

  context 'when viewing teams and mentors' do
    it 'displays all teams, members, and mentors' do
      visit teams_path
      expect(page).to have_content(@team.name)
      expect(page).to have_content(@mentor.name)
      expect(page).to have_content(@instructor.name)
    end
  end

  context 'when a mentor adds/edit meeting dates for their team' do
    it 'allows mentors to add a meeting date' do
      sign_in(@mentor) # Assuming you have a method for signing in
      visit team_path(@team)
      click_button 'Add Meeting Date'
      fill_in 'Meeting Date', with: '2024-11-01'
      click_button 'Save'

      expect(page).to have_content('Meeting Date added successfully')
      expect(page).to have_content('2024-11-01')
    end

    it 'allows mentors to edit a meeting date' do
      sign_in(@mentor)
      visit team_path(@team)
      click_link 'Edit Meeting Date'
      fill_in 'Meeting Date', with: '2024-11-15'
      click_button 'Save'

      expect(page).to have_content('Meeting Date updated successfully')
      expect(page).to have_content('2024-11-15')
    end
  end

  context 'when an instructor edits meeting dates for all teams' do
    it 'allows instructors to edit meeting dates' do
      sign_in(@instructor)
      visit team_path(@team)
      click_link 'Edit Meeting Date'
      fill_in 'Meeting Date', with: '2024-11-20'
      click_button 'Save'

      expect(page).to have_content('Meeting Date updated successfully')
      expect(page).to have_content('2024-11-20')
    end
  end

  context 'when inputting multiple meeting dates' do
    it 'allows input of multiple meeting dates' do
      sign_in(@mentor)
      visit team_path(@team)
      click_button 'Add Multiple Meeting Dates'
      fill_in 'Meeting Dates', with: '2024-11-01, 2024-11-08'
      click_button 'Save'

      expect(page).to have_content('Meeting Dates added successfully')
      expect(page).to have_content('2024-11-01')
      expect(page).to have_content('2024-11-08')
    end
  end

  context 'when handling under-capacity teams' do
    it 'disables date fields for under-capacity teams' do
      sign_in(@mentor)
      visit team_path(@under_capacity_team)

      expect(page).to have_selector('input[disabled]', id: 'meeting_date')
    end
  end
end
