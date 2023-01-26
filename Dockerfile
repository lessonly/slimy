FROM ruby:2.6.5

RUN apt-get update -qq && apt-get install -y nano zsh && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    echo "source ~/.bashrc" >> ~/.zshrc && \
    # Fix slow zsh terminal with docker sync git volume https://github.com/ohmyzsh/ohmyzsh/issues/5066
    git config --global --add oh-my-zsh.hide-dirty 1

RUN mkdir /slimy /slimy/lib /slimy/lib/slimy
WORKDIR /slimy
RUN gem install bundler -v "2.3.8"
COPY Gemfile /slimy/Gemfile
COPY Gemfile.lock /slimy/Gemfile.lock
COPY slimy.gemspec /slimy/slimy.gemspec
COPY lib/slimy/version.rb /slimy/lib/slimy/version.rb
RUN bundle install
COPY . /slimy
