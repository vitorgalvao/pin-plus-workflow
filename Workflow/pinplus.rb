require 'cgi'
require 'fileutils'
require 'json'
require 'open-uri'
require 'open3'

Pinboard_token = ENV['api_key']
Last_access_file = "#{ENV['alfred_workflow_cache']}/last_access_file.txt".freeze
All_bookmarks_json = "#{ENV['alfred_workflow_cache']}/all_bookmarks.json".freeze
Unread_bookmarks_json = "#{ENV['alfred_workflow_cache']}/unread_bookmarks.json".freeze

def notification(message, title = ENV['alfred_workflow_name'])
  system("#{Dir.pwd}/notificator", '--message', message, '--title', title)
end

def success_sound
  system('afplay', '/System/Library/Sounds/Tink.aiff')
end

def error_sound
  system('afplay', '/System/Library/Sounds/Sosumi.aiff')
end

def error(message)
  error_sound
  notification(message)
  abort(message)
end

def add_unread(url, title)
  success_sound
  notification(url, title)

  url_encoded = CGI.escape(url)
  title_encoded = CGI.escape(title)

  result = JSON.parse(URI("https://api.pinboard.in/v1/posts/add?url=#{url_encoded}&description=#{title_encoded}&toread=yes&auth_token=#{Pinboard_token}&format=json").read)['result_code']

  return if result == 'done'

  error_log = "#{ENV['HOME']}/Desktop/pinplus_errors.log"

  reason = status.nil? ? 'Got no reply from server.' : result
  File.write(error_log, "---\n", mode: 'a') if File.exist?(error_log)

  File.write(error_log, "error: #{reason}\ntitle: #{title}\nurl: #{url}\nencoded title: #{title_encoded}\nencoded url: #{url_encoded}\n", mode: 'a')

  error('Error adding bookmark. See error log in Desktop.')
end

def synced_with_website?
  FileUtils.mkdir_p(ENV['alfred_workflow_cache']) unless Dir.exist?(ENV['alfred_workflow_cache'])

  last_access_local = File.exist?(Last_access_file) ? File.read(Last_access_file) : 'File does not yet exist'
  last_access_remote = JSON.parse(URI("https://api.pinboard.in/v1/posts/update?auth_token=#{Pinboard_token}&format=json").read)['update_time']

  return true if last_access_local == last_access_remote

  File.write(Last_access_file, last_access_remote)
  false
end

def action_unread(action, url)
  url_encoded = CGI.escape(url)

  if action == 'delete'
    URI("https://api.pinboard.in/v1/posts/delete?url=#{url_encoded}&auth_token=#{Pinboard_token}").open
    return
  end

  return unless action == 'archive'

  toread = 'no'

  bookmark = JSON.parse(URI("https://api.pinboard.in/v1/posts/get?url=#{url_encoded}&auth_token=#{Pinboard_token}&format=json").read)['posts'][0]

  title_encoded = CGI.escape(bookmark['description'])
  description_encoded = CGI.escape(bookmark['extended'])
  shared = bookmark['shared']
  tags_encoded = CGI.escape(bookmark['tags'])

  URI("https://api.pinboard.in/v1/posts/add?url=#{url_encoded}&description=#{title_encoded}&extended=#{description_encoded}&shared=#{shared}&toread=#{toread}&tags=#{tags_encoded}&auth_token=#{Pinboard_token}")
end

def show_bookmarks(bookmarks_file)
  fetch_bookmarks
  puts File.read(bookmarks_file)
end

def fetch_bookmarks
  return if synced_with_website?

  all_bookmarks = JSON.parse(URI("https://api.pinboard.in/v1/posts/all?auth_token=#{Pinboard_token}&format=json").read)

  unread_bookmarks = []
  all_bookmarks.each do |bookmark|
    next unless bookmark['toread'] == 'yes'

    ENV['sort_unread_newest'] == '1' ? unread_bookmarks.push(bookmark) : unread_bookmarks.unshift(bookmark)
  end

  write_bookmarks(all_bookmarks, All_bookmarks_json, false)
  write_bookmarks(unread_bookmarks, Unread_bookmarks_json, true)
end

def write_bookmarks(bookmarks, bookmarks_file, skip_knowledge)
  sf_items = bookmarks.each_with_object([]) do |bookmark, items|
    # More searcheable URL
    split_href = bookmark['href'].split('/').reject { |a| a.start_with?('http') || a.empty? }.join(' ').sub('www.', '')

    # Available actions for modifiers
    actions = {
      open_url: { subtitle: "Open #{bookmark['href']}" },
      copy_url: { subtitle: 'Copy link to clipboard' },
      view_tags: { subtitle: bookmark['tags'].empty? ? '[No tags]' : bookmark['tags'] },
      view_description: { subtitle: bookmark['extended'].empty? ? '[No description]' : bookmark['extended'] },
      pinboard_site: { subtitle: 'Open bookmark on Pinboard’s site' },
      download_video: { subtitle: 'Download video to watch later' }
    }

    # Each action has a variable with the same name
    actions.keys.each do |key|
      actions[key][:variables] = { action: key.to_s }
    end

    # Populate modifiers
    modifiers = {
      cmd: actions[ENV['mod_cmd'].to_sym],
      alt: actions[ENV['mod_alt'].to_sym],
      ctrl: actions[ENV['mod_ctrl'].to_sym],
      shift: actions[ENV['mod_shift'].to_sym],
      'cmd+alt+ctrl': { variables: { action: 'fetch_bookmarks' }, subtitle: 'Force Cache Update' }
    }

    items.push({
      variables: { action: ENV['mod_none'] },
      uid: bookmark['href'],
      title: bookmark['description'],
      subtitle: bookmark['href'],
      match: "#{bookmark['description']} #{split_href} #{bookmark['extended']} #{bookmark['tags']}",
      mods: modifiers,
      arg: bookmark['href']
    })
  end

  File.write(bookmarks_file, {
    cache: { seconds: 3600, loosereload: true },
    skipknowledge: skip_knowledge,
    items: sf_items
  }.to_json)
end

def search_in_website(url)
  username = Pinboard_token.sub(/:.*/, '')
  print "https://pinboard.in/search/u:#{username}?query=#{url.sub(%r{^(http[s]|ftp)://}, '')}".strip
end
