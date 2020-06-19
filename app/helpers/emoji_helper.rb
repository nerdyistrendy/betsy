# Taken from https://github.com/jollygoodcode/twemoji

module EmojiHelper
  def emojify(content, **options)
    Twemoji.parse(h(content), options).html_safe if content.present?
  end
end

# Used in erb using keywords from
# https://github.com/jollygoodcode/emoji-keywords
# Using this this syntax:

# <p><%= emojify "I like chocolate :heart_eyes:!" %></p>
# would render:
# <p>I like chocolate <img class="emoji" draggable="false" title=":heart_eyes:" alt="😍" src="https://twemoji.maxcdn.com/2/72x72/1f60d.png">!</p>