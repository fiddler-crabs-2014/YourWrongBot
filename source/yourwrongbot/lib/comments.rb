require 'snoo'

bot = Snoo::Client.new
bot.log_in 'yourwrongbot', '42crabs'

config = { bot: bot, current_sub: 'programming' }



class RedditParser
  attr_accessor :current_sub
  def initialize(args)
    @bot = args.fetch(:bot)
    @current_sub = args.fetch(:current_sub)
  end

  def link_ids
    unformatted_subreddit = (@bot.get_listing subreddit: current_sub)
    subreddit_in_json = JSON.parse((unformatted_subreddit).body)
    links = subreddit_in_json["data"]["children"].map{ |link| link["data"]["id"] }
  end

  def comments_from(link_id, num_comments)
    comments = JSON.parse((@bot.get_comments subreddit: current_sub, link_id: link_id, limit: num_comments ).body)
  end

  def format_posts(posts)
    posts.map do |post|
      posts_comments = post["data"]["children"]
      unless posts_comments.empty?
        posts_comments.map do |comment|
          username = comment["data"]["author"]
          id = comment["data"]["id"]
          body = comment["data"]["body"]
          Comment.new(username: username, comment_id: id, body: body)
        end
      end
    end.compact
  end

end

class Comment
  attr_reader :username, :comment_id, :body
  def initialize(args)
    @username = args.fetch(:username)
    @comment_id = args.fetch(:comment_id)
    @body = args.fetch(:body)
  end
end

yourwrong = RedditParser.new(config)

yourwrong.link_ids.each do | link_id |
  puts "-"*70
  yourwrong.format_posts(yourwrong.comments_from(link_id, 5)).each do | comments |
    comments.each do |comment|
      puts "*"*70
      puts "username: #{comment.username}"
      puts "comment id: #{comment.comment_id}"
      puts "body: #{comment.body}"
    end
  end
  puts "-"*70
  sleep(2.1)
end