function hfun_bar(vname)
    val = Meta.parse(vname[1])
    return round(sqrt(val), digits = 2)
end

function hfun_m1fill(vname)
    var = vname[1]
    return pagevar("index", var)
end

function lx_baz(com, _)
    # keep this first line
    brace_content = Franklin.content(com.braces[1]) # input string
    # do whatever you want here
    return uppercase(brace_content)
end

function hfun_blog_card(vname)
    page_path = vname[1]
    
    # Get page variables
    title = pagevar(page_path, "title")
    date = pagevar(page_path, "date")
    description = pagevar(page_path, "description")
    
    # Format date
    date_str = isnothing(date) ? "No date" : string(date)
    
    # Get image based on page
    image_map = Dict(
        "blog_pages/cache_modeling_basics" => "/assets/main_image.png",
        "blog_pages/ibmq" => "/assets/quantum-computing.svg", 
        "blog_pages/cache_modeling_implementation" => "/assets/cache_model_hierarchyex.png"
    )
    
    image_src = get(image_map, page_path, "/assets/generic-blog-image.svg")
    
    # Generate HTML
    html = """
    <article class="blog-card">
      <div class="blog-card-image">
        <img src="$image_src" alt="$title" />
      </div>
      <div class="blog-card-content">
        <h3 class="blog-card-title">$title</h3>
        <div class="blog-card-meta">
          <span class="blog-card-date">$date_str</span>
        </div>
        <p class="blog-card-excerpt">
          $description
        </p>
        <a href="/$page_path/" class="blog-card-link">Read More</a>
      </div>
    </article>
    """
    
    return html
end
