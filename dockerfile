FROM vicxu/rbenv:v1

RUN apt-get update && apt-get install -y libpq-dev
RUN rbenv install 2.5.5

ENV WORK_PAH = codepraise-api
RUN cd root && mkdir $WORK_PAH
WORKDIR root/codepraise-api
COPY . .
RUN rbenv global 2.5.5 && gem install bundler:1.17.3 && bundle install && bundle install --with production

CMD 'bash'
