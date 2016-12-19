module ApplicationHelper
  
  
  #Returns the full title for the page
  def full_title(page_title = '')
    base_title = "The 21st Century Buttedongue Society"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end
end
