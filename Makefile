test:
	gem build nordigen_ob_client.gemspec
	gem install nordigen_ob_client-0.0.5.gem
	ruby test.rb

rebuild:
	gem build nordigen_ob_client.gemspec
	gem install nordigen_ob_client-0.0.5.gem

publish:
	gem push nordigen_ob_client-0.0.5.gem