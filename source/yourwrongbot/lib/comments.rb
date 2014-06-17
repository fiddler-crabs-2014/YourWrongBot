require 'snoo'

bot = Snoo::Client.new
bot.log_in 'yourwrongbot', '42crabs'

config = { bot: bot, current_sub: 'jokes' }



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
      # puts JSON.pretty_generate post
      format_comments_from(post)
    end.compact
  end

  def format_comments_from(post)
    post["data"]["children"].map do |comment|
      format_comment(comment)
    end.compact
  end

  def format_comment(comment)
    unless comment["data"]["body"].nil?
      Comment.new(username: comment["data"]["author"], 
                  comment_id: comment["data"]["id"], 
                  body: comment["data"]["body"],
                  link_id: comment["data"]["link_id"][3..-1])
    end
  end

end

class Comment
  attr_reader :username, :comment_id, :body, :link_id
  def initialize(args)
    @username = args.fetch(:username)
    @comment_id = args.fetch(:comment_id)
    @body = args.fetch(:body)
    @link_id = args.fetch(:link_id)
  end
end

yourwrong = RedditParser.new(config)

yourwrong.link_ids.each do | link_id |
  puts "-"*70
  yourwrong.format_posts(yourwrong.comments_from(link_id, 5)).each do | comments |
    comments.each do |comment|
      puts "*"*70
      puts "link id: #{comment.link_id}"
      puts "username: #{comment.username}"
      puts "comment id: #{comment.comment_id}"
      puts "body: #{comment.body}"
    end
  end
  puts "-"*70
  sleep(2.1)
end