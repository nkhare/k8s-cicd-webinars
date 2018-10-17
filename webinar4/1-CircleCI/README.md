## Prerequisites
- GitHub Account

## CircleCI
- Sign Up at [CircleCI](https://circleci.com/) using GitHub credentials.
- Fork the [RSVPAPP](https://github.com/cloudyuga/rsvpapp.git) repository to your GitHub account.
- Go to the your forked RSVPAPP repository. and add the CircleCI configuration file.

- Add `.circleci/config.yml` file to your forked RSVPAPP repository as shown below.

```yml

version: 2
jobs:
  test:
    machine:
      image: circleci/classic:201808-01
      docker_layer_caching: true
    working_directory: ~/repo
          
    steps:
      - checkout
      - run:
          name: install dependencies
          command: |
            sudo rm /var/lib/dpkg/lock
            sudo dpkg --configure -a
            sudo apt-get install software-properties-common
            sudo add-apt-repository ppa:fkrull/deadsnakes
            sudo apt-get update
            sleep 5
            sudo rm /var/lib/dpkg/lock
            sudo dpkg --configure -a
            sudo apt-get install python3.5
            sleep 5
            python -m pip install -r requirements.txt
        
      # run tests!
      # this example uses Django's built-in test-runner
      # other common Python testing frameworks include pytest and nose
      # https://pytest.org
      # https://nose.readthedocs.io
      
      - run:
          name: run tests
          command: |
            python -m pytest tests/test_rsvpapp.py  

  build:
  
    machine:
      image: circleci/classic:201808-01
      docker_layer_caching: true
    working_directory: ~/repo
          
    steps:
      - checkout 
      - run:
          name: build image
          command: |
            docker build -t $DOCKERHUB_USERNAME/rsvpapp:$CIRCLE_SHA1 .
 
  push:
    machine:
      image: circleci/classic:201808-01
      docker_layer_caching: true
    working_directory: ~/repo
    steps:
      - checkout 
      - run:
          name: Push image
          command: |
            docker build -t $DOCKERHUB_USERNAME/rsvpapp:$CIRCLE_SHA1 .
            echo $DOCKERHUB_PASSWORD | docker login --username $DOCKERHUB_USERNAME --password-stdin
            docker push $DOCKERHUB_USERNAME/rsvpapp:$CIRCLE_SHA1	

workflows:
  version: 2
  build-deploy:
    jobs:
      - test:
          context: DOCKERHUB
          filters:
            branches:
              only: dev        
      - build:
          context: DOCKERHUB 
          requires:
            - test
          filters:
            branches:
              only: dev
      - push:
          context: DOCKERHUB
          requires:
            - build
          filters:
            branches:
              only: dev


```


- Now go to the [CircleCI](https://circleci.com/)
