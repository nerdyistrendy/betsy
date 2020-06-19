# Taken from https://github.com/jollygoodcode/twemoji

module EmojiHelper
  def emojify(content, **options)
    Twemoji.parse(h(content), options).html_safe if content.present?
  end
end