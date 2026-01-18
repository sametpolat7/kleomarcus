module Public::HomeHelper
  def star_rating(rating = 5, label: nil)
    label ||= "#{rating} yıldız değerlendirme"

    full_stars = rating.floor
    half_star = (rating % 1) >= 0.5
    empty_stars = 5 - full_stars - (half_star ? 1 : 0)

    content_tag(:div, class: "flex gap-1 mt-4", role: "img", "aria-label": label) do
      stars = []

      # Full stars
      full_stars.times do
        stars << content_tag(:svg, class: "w-5 h-5 text-primary", fill: "currentColor", viewBox: "0 0 20 20", "aria-hidden": "true") do
          tag.path(d: "M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z")
        end
      end

      # Half star
      if half_star
        stars << content_tag(:svg, class: "w-5 h-5 text-primary", viewBox: "0 0 20 20", "aria-hidden": "true") do
          tag.defs do
            tag.linearGradient(id: "half-star-gradient") do
              safe_join([
                tag.stop(offset: "50%", "stop-color": "currentColor"),
                tag.stop(offset: "50%", "stop-color": "transparent")
              ])
            end
          end +
          tag.path(d: "M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z", fill: "url(#half-star-gradient)", stroke: "currentColor", "stroke-width": "1")
        end
      end

      # Empty stars
      empty_stars.times do
        stars << content_tag(:svg, class: "w-5 h-5 text-primary", fill: "none", stroke: "currentColor", "stroke-width": "1", viewBox: "0 0 20 20", "aria-hidden": "true") do
          tag.path(d: "M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z")
        end
      end

      safe_join(stars)
    end
  end
end
