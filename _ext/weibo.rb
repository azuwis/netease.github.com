# encoding: utf-8
require 'mechanize'
require 'pry'

class Weibo
  def initialize()
    @agent = Mechanize.new
    @agent.user_agent = Mechanize::AGENT_ALIASES['iPhone']
    @agent.follow_meta_refresh = true
    login
  end

  def login()
    @agent.get('http://weibo.cn/')
    @agent.page.link_with(:text => '登录').click
    form = @agent.page.form
    form.mobile = ''
    form.field_with(type: 'password').value = ''
    @agent.submit(form, form.buttons.first)
  end

  def info(screen_name)
    @agent.get(URI::encode("http://weibo.com/n/#{screen_name}"))
    @agent.page.link_with(text: '资料').click
    avatar = @agent.page.image_with(alt: '头像').src
    {:avatar => avatar}
    # binding.pry
  end
end
