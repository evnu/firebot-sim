FROM elixir:1.20

COPY . /usr/local/app

WORKDIR /usr/local/app

RUN mix deps.get
RUN mix compile
RUN mix release

CMD ["bash", "start.sh"]
