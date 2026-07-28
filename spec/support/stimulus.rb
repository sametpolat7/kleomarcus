module StimulusReady
  def wait_for_stimulus(*identifiers)
    registered = "window.Stimulus.router.modules.map((module) => module.identifier)"

    identifiers.each do |identifier|
      Timeout.timeout(Capybara.default_max_wait_time) do
        sleep 0.05 until page.evaluate_script("!!window.Stimulus && #{registered}.includes('#{identifier}')")
      end
    end
  end
end

RSpec.configure do |config|
  config.include StimulusReady, type: :system
end
