require 'bundler'
Bundler.require

Dotenv.configure(
  'GITHUB_ACCESS_TOKEN' => 'visit https://github.com/settings/tokens/new'
)

Octokit.configure do |c|
  c.access_token = ENV['GITHUB_ACCESS_TOKEN']
end

loop do
  notifications = Octokit.notifications(all: true).select {|i| %w(mention).include? i.reason }
  last_notification = notifications.first
  if !@last_update or @last_update < last_notification.updated_at
    target_pr = last_notification.subject.rels[:self].get.data
    comments = target_pr.rels[:comments].get.data
    if comments.empty?
      p target_pr.body
    else
      p comments.last.body
    end
    @last_update = last_notification.updated_at
  end
  puts "."
  sleep 10
end
