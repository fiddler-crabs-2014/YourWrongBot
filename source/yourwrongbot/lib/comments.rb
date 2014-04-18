require 'snoo'

bot = Snoo::Client.new
bot.log_in 'yourwrongbot', '42crabs'

config = { bot: bot}



class RedditParser
  attr_accessor :current_sub
  def initialize(args)
    @bot = args.fetch(:bot)
    @current_sub = ""
  end

  def get_link_ids_from_subreddit
    unformatted_subreddit = (@bot.get_listing subreddit: current_sub)
    subreddit_in_json = JSON.parse((unformatted_subreddit).body)
    links = subreddit_in_json["data"]["children"].map do |link|
      link["data"]["id"]
    end
    links
  end

  def get_comments_from_link(link_id, num_comments)
    comments = JSON.parse((@bot.get_comments subreddit: current_sub, link_id: link_id ).body)
  end

  def format_comments(comments)
    comments.map do |comment|
      # puts JSON.pretty_generate(comment)
      username = comment["data"]["children"].first["data"]["author"]
      id = comment["data"]["children"].first["data"]["id"]
      body = comment["data"]["children"].first["data"]["body"]
      Comment.new(username: username, comment_id: id, body: body)
    end
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
yourwrong.current_sub = 'programming'
yourwrong.get_link_ids_from_subreddit.each do | link_id |
  puts "-"*70
  yourwrong.format_comments(yourwrong.get_comments_from_link(link_id, 5)).each do | comment |
    puts "*"*70
    puts "username: #{comment.username}"
    puts "comment id: #{comment.comment_id}"
    puts "body: #{comment.body}"
  end
  puts "-"*70
  sleep(2.1)
end




# #get post for subreddit
# j = JSON.parse((reddit.get_listing subreddit: 'programming').body)
# # post id
# # p j["data"]["children"].first["data"]["id"]
# # # number of comments onpost
# # p j["data"]["children"].first["data"]["num_comments"]
# links_in_subreddit = j["data"]["children"]
# # 5.times do
#   #get comments for a post
#   puts "This is a new thread!!!"
#   puts "------------------------------------------------"
#   puts "how many comments = #{j["data"]["children"].length}"
#   links_in_subreddit[0..4].each do | link |
#     link_id = link["data"]["id"]
#     comments = JSON.parse((reddit.get_comments subreddit: 'programming', link_id: link_id ).body)
#   # get comment text

#   # 5.times do
#     p comments.last["data"]["children"].first["data"]["author"]
#     p comments.last["data"]["children"].first["data"]["body"]
#     comments.last["data"]["children"].shift["data"]["body"]
#     puts " "
#   # end

#   comments = JSON.parse((reddit.get_comments subreddit: 'programming', link_id: j["data"]["children"].shift["data"]["id"]).body)
#   sleep(2.1)
# # end
# end



# #get comments for a post
# comments = JSON.parse((reddit.get_comments subreddit: 'programming', link_id: j["data"]["children"].first["data"]["id"]).body)
# # get comment text
# puts j["data"]["children"].first["data"]["id"]
# reddit.comment
# puts JSON.pretty_generate(JSON.parse(reddit.get_comments subreddit: 'programming', link_id: "cgvtv2u"))
# # puts JSON.pretty_generate(comments)
# # 5.times do
# #   p comments.last["data"]["children"].first["data"]["author"]
# #   p comments.last["data"]["children"].first["data"]["name"]
# #   p comments.last["data"]["children"].first["data"]["body"]
# #   comments.last["data"]["children"].shift["data"]["body"]
# #   puts " "
# # end
