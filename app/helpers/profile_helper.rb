module ProfileHelper
  def auto_complete_text_field(object, method, tag_options = {}, completion_options = {})
    if(tag_options[:index])
      tag_name = "#{object}_#{tag_options[:index]}_#{method}"
    else
      tag_name = "#{object}_#{method}"
    end
    (completion_options[:skip_style] ? "" : auto_complete_stylesheet) +
        text_field(object, method, tag_options) +
        content_tag("div", "", :id => tag_name + "_auto_complete", :class => "auto_complete") +
        auto_complete_field(tag_name, { :url => { :action => "auto_complete_for_#{object}_#{method}" } }.update(completion_options))
  end
end
