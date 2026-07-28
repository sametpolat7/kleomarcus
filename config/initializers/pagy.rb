require "pagy"
require "pagy/extras/overflow"

Pagy::DEFAULT[:limit] = 10
Pagy::DEFAULT[:overflow] = :last_page
