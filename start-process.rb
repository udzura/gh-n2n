require 'bundler'
Bundler.require

Dotenv.configure(
  'GITHUB_ACCESS_TOKEN' => 'visit https://github.com/settings/tokens/new'
)

Octokit.configure do |c|
  c.access_token = ENV['GITHUB_ACCESS_TOKEN']
end

loop do
  notifications = Octokit.notifications(all: true).select {|i| %w(mention team_mention).include? i.reason }
  checked = Time.now
  last_notification = notifications.first
  if !@last_update or @last_update < last_notification.updated_at.localtime
    notifications.reverse_each do |notification|
      next if @last_update && notification.updated_at < @last_update
      target_pr = notification.subject.rels[:self].get.data
      comments = target_pr.rels[:comments].get.data
      entry = if comments.empty?
                target_pr
              else
                comments.last
              end
      puts "URL: %s" % entry.html_url
      puts "Created at: %s" % entry.created_at.localtime
      puts entry.body.lines.map{|l| l.sub(/\A/, "\t") }.join
      puts "-" * 120
    end
    @last_update = checked
  end
  puts Time.now
  sleep 60
end
