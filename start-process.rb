require 'bundler'
Bundler.require

Dotenv.configure(
  'GITHUB_ACCESS_TOKEN' => 'visit https://github.com/settings/tokens/new'
)

Octokit.configure do |c|
  c.access_token = ENV['GITHUB_ACCESS_TOKEN']
end

loop do
  notifications = Octokit.notifications(all: true, participating: true).select {|i| %w(mention).include? i.reason }
  last_notification = notifications.first
  if !@last_update or @last_update < last_notification.updated_at
    notifications.reverse_each do |notification|
      target_pr = notification.subject.rels[:self].get.data
      comments = target_pr.rels[:comments].get.data
      url = nil
      if comments.empty?
        puts target_pr.body.lines.map{|l| l.sub(/\A/, "\t") }.join
        url = target_pr.html_url
      else
        comment = comments.last
        puts comment.body.lines.map{|l| l.sub(/\A/, "\t") }.join
        url = comment.html_url
      end
      puts "URL: %s" % url
      puts "-" * 120
    end
    @last_update = last_notification.updated_at
  end
  puts Time.now
  sleep 60
end
