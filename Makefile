test:
	gem build nordigen_ob_client.gemspec
	gem install nordigen_ob_client-0.0.4.gem
	ruby test.rb

rebuild:
	gem build nordigen_ob_client.gemspec
	gem install nordigen_ob_client-0.0.4.gem
