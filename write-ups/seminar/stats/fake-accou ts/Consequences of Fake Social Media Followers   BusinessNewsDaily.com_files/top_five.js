
  var top_five = [{"pageviews":20985,"name":"50+ Job Skills You Should List on Your Resume","img":"<img src=\"http://www.businessnewsdaily.com/images/i/745/i84/now-hiring-11080302.jpg?1323472506\" alt=\"now-hiring-11080302\" />","path":"/2135-job-skills-resume.html","formatted":"20,985"},{"pageviews":7452,"name":"30 Big Ideas, Trends and Predictions for 2012","img":"<img src=\"http://www.businessnewsdaily.com/images/i/1421/i84/lightbulb-art.jpg?1325415945\" alt=\"\" />","path":"/1849-business-trends-2012.html","formatted":"7,452"},{"pageviews":6616,"name":"The Best Job Interview Questions You  Should Ask","img":"<img src=\"http://www.businessnewsdaily.com/images/i/886/i84/handshake-11091202.jpg?1323472703\" alt=\"handshake-11091202\" />","path":"/1452-best-job-interview-questions.html","formatted":"6,616"},{"pageviews":5525,"name":"What Is Leadership?","img":"<img src=\"http://www.businessnewsdaily.com/images/i/1062/i84/female-boss-11102402.jpg?1323472944\" alt=\"female-boss-11102402\" />","path":"/2730-leadership.html","formatted":"5,525"},{"pageviews":3347,"name":"What Is Accounting?","img":"<img src=\"http://www.businessnewsdaily.com/images/i/2483/i84/accounting-chart.jpg?1339671821\" alt=\"\" />","path":"/2689-accounting.html","formatted":"3,347"}]
  var rank_max = top_five[0].pageviews
  
  function get_top_five(){
    var articles ='<div class="most_pop_b"><div class="side_row">';
    articles += '<div class="category_title">';
    articles += '   MOST POPULAR ARTICLES';
    articles += '</div>';
    articles += '';
    for (asset in top_five){
      articles += '<div class="mp_row">';
      articles += '  <a href="'+ top_five[asset].path +'">';
      articles += '    <div class="mp_sub">';
      articles += '      <div class="mp_img">';
      articles += '        <span class="img_overlay overlay_i84"></span>';
      articles += '        '+ top_five[asset].img;
      articles += '      </div>';
      articles += '      <div class="mp_text">'
      articles += '        <div class="mp_title">';
      articles += '          '+ top_five[asset].name.substr(0, 70)+((top_five[asset].name.length > 70) ? '...' : '') ;
      articles += '        </div>';
      articles += '        <div class="mp_views">';
      articles += '          <div class="mp_bar" style="width:'+ ((top_five[asset].pageviews/rank_max)*50) +'%;" ></div>';
      articles += '            '+ top_five[asset].formatted +' views';
      articles += '        </div>';
      articles += '      </div>';
      articles += '    </div>';
      articles += '  </a>';
      articles += '</div>' +"\n";
    }
    articles += '<div class="mp_sub"></div>';
    articles += '</div></div>';
    return articles
  }
