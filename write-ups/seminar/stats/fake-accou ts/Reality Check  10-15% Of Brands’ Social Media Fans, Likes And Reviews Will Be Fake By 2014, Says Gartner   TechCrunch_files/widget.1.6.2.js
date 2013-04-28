(function() {
  function enable_tooltip() {
    var timer = 0;

    $grv("#g_personalization, #grv_tooltip").bind('mouseenter', function() {
      clearTimeout(timer);

      $grv('#grv_tooltip').fadeIn('fast', function() {
        $grv('#grv_tooltip > *').fadeIn();
      });
    });

    $grv('#grv_tooltip').bind('mouseenter', function() {
      clearTimeout(timer);
    });

    function hide() {
      $grv('#grv_tooltip > *').fadeOut(50, function() {
        $grv('#grv_tooltip').fadeOut('fast');
      });
    }

    $grv("#g_personalization, #grv_tooltip").bind('mouseleave', function() {
      timer = setTimeout(hide, 100);
    });
  }

  enable_tooltip();
})();

var grvNoFinalSlashUrl = /^[^#?]*/.exec(window.location.href)[0];

function grvQueryString() {
  return (/\?([^#]*)/.exec(window.location.href)||[])[0] || '';
}

function grvScaleImages() {
  $grv('.grv_article_img').each(function() {
    var img = $grv(this),
      cntr_width = img.parent().width(),
      cntr_height = img.parent().height(),
      parent_ratio = cntr_width/cntr_height,
      in_memory_img = $grv("<img/>");

    in_memory_img
      .load(function() {
        var pic_real_width = this.width,   // Note: $grv(this).width() will not
          pic_real_height = this.height,   // work for in memory images.
          pic_ratio = pic_real_width/pic_real_height,
          posX;

        if (parent_ratio < pic_ratio) {
          posX = -(((pic_real_width/pic_real_height)*cntr_height)-cntr_width)/2;
          img.addClass('height');
          img.css("left", posX);
        } else {
          img.addClass('width');
        }
      })
      .attr("src", img.attr("src"));
  });
}

function grvVerticalSpace() {
  var vert_margin;
  var totalElementsHeight;
  var totalSpaces = 2; // Accounts for the top and bottom

  if (!grvDoVerticalSpace) {
    return;
  }

  totalElementsHeight = $grv('#grv_best_stories h3').outerHeight();

  totalSpaces += $grv('.grv_article').length;
  $grv('.grv_article').each(function(index) {
      totalElementsHeight += $grv(this).outerHeight();
  });

  if ($grv('#what_is_g').is(":visible")) {
    totalElementsHeight += $grv('#what_is_g').outerHeight();
    totalSpaces++;
  }

  vert_margin = ($grv('#grv_best_stories').innerHeight()-totalElementsHeight)/totalSpaces;

  $grv('.grv_article').css("margin-top",vert_margin);
  $grv('#grv_best_stories h3').css("margin-top",vert_margin);
  $grv('#what_is_g').css("margin-top",vert_margin);
}

// Specifically for the basic horizontal image slider widget - i.e. - TechCrunch & Dying Scene
function grvHorizontalSpace() {
  var widget_width, article_width;

  if (!grvDoHorizontalSpace) {
    return;
  }

  widget_width = $grv('#grv_best_stories').innerWidth()-($grv('.grv_article').length-1)*5;
  article_width = widget_width/$grv('.grv_article').length;

  $grv('.grv_img_link').css('width', article_width-2);
  $grv('.post_type').css('width', article_width-2);
  $grv('.grv_article').each(function(index) {
      //alert(index + ': ' + $grv(this).text());
      $grv(this).css('width', article_width);
      if ( index < $grv('.grv_article').length-1) {
        $grv(this).css('margin-right', '5px');
      }
  });
  $grv('.grv_article').css('width', article_width);
  grvScaleImages();
}

function grvTrimTitles() {
  $grv('.grv_article_title, .article_content').dotdotdot();
}

function grvRatingMouseenter() {
  $grv(this).siblings($grv(this).is('.thumbs_up') ? '.rate_up_info' : '.rate_down_info').show();
}

function grvRatingMouseleave() {
  $grv(this).siblings('.rating_info').hide();
}

function grvBindArticleHandlers($grvparent) {
  var articles, alignPostType, handleBrokenImg;

  $grvparent.find('[data-forward-href]').click(function() {
    var targetHref = $grv(this).attr('data-forward-href');
    if (targetHref) {
      $grv(this).attr('href', targetHref);
    }
  });

  if (grvShowMouseoverSlide) {
    articles = $grvparent.is('.grv_article') ? $grvparent : $grvparent.find('.grv_article');
    articles
      .mouseover(function() { $grv(this).children('.grv_img_link').stop().animate({"top": "80px"}, "fast"); })
      .mouseout(function() { $grv(this).children('.grv_img_link').stop().animate({"top": "34px"}, "fast"); })
      ;
  }


  $grvparent.find('.thumb_rating')
    .bind('mouseenter', grvRatingMouseenter)
    .bind('mouseleave', grvRatingMouseleave)
    .click(grvRateClick)
    ;

  alignPostType = function() {
    var $grvimg = $grv(this);
    var $grvimgContainer = $grvimg.parent();
    if ($grvimg.height() < $grvimgContainer.height()) {
      $grvimg.siblings('.post_type').css('bottom', ($grvimgContainer.height() - $grvimg.height()) + 'px');
    }
  };
  handleBrokenImg = function() { $grv(this).attr('src', grvBrokenImgUrl); };
  $grvparent.find('.grv_article_img')
    .load(alignPostType)
    .one('error', handleBrokenImg)
    .filter('[src=""]').each(handleBrokenImg)
    ;

  grvScaleImages();
  grvTrimTitles();
  grvVerticalSpace();

  $grvparent.find('.subscriber_only')
    .bind('mouseenter', function() { $grv(this).siblings('.subscriber_info').show(); })
    .bind('mouseleave', function() { $grv(this).siblings('.subscriber_info').hide(); })
    ;
}

function grvRateClick() {
  var $grvrating = $grv(this);
  var $grvarticle = $grvrating.parents('.grv_article');
  var $grvthisArticlesRatings = $grvrating.add($grvrating.siblings('.thumb_rating')),
    startTime = +new Date(),
    ratingStr, ratingUrl, ratedConfirmationClass = '', $grvratedConfirmation, likeSuccess, dislikeSuccess, onSuccessFade;

  $grvarticle
    .unbind('mouseover')
    .unbind('mouseout')
    ;

  $grvthisArticlesRatings
    .unbind('mouseenter')
    .unbind('mouseleave')
    .unbind('click')
    ;

  if ($grvrating.is('.thumbs_up') && $grvrating.parent('.selected').length) {
    ratingStr = 'unlike';
  }
  else if ($grvrating.is('.thumbs_up')) {
    ratingStr = 'like';
    ratedConfirmationClass = '.rated_up_info';
  }
  else {
    ratingStr = 'dislike';
    ratedConfirmationClass = '.rated_down_info';
  }

  $grvratedConfirmation = $grvrating.siblings('.rating_info').hide();
  if (ratedConfirmationClass) {
    $grvratedConfirmation = $grvratedConfirmation.filter(ratedConfirmationClass).show();
  }
  else {
    $grvratedConfirmation = $grvratedConfirmation.filter(':first');
  }

  likeSuccess = function() {
    grvBindArticleHandlers($grvrating.parent());
    $grvthisArticlesRatings.parent('.ratings').toggleClass('selected');
  };

  dislikeSuccess = function(newArticleHtml) {
    if (newArticleHtml) {
      $grvarticle.html(newArticleHtml)
    }
    grvBindArticleHandlers($grvarticle);
  };

  onSuccessFade = function(respData) {
    var endTime = +new Date();
    var timeout = Math.max(0, 1500 - (endTime - startTime));
    setTimeout(function() {
      var rateCallback = ratingStr === 'dislike' ? dislikeSuccess : likeSuccess;
      $grvratedConfirmation.fadeOut('slow', function() { rateCallback(respData); });
    }, timeout);
  };

  ratingUrl = grvNoFinalSlashUrl + '/rate/' + ratingStr + grvQueryString();
  $grv.ajax({
    url: ratingUrl,
    data: {
      url: $grvrating.parents('.grv_article').find('.grv_article_title').attr('href'),
      existingUrls: $grvrating.parents('.grv_article').siblings().find('.grv_article_title').map(function(i, el) {
          return $grv(el).attr('href');
        }).get().join(';')
    },
    type: 'POST',
    success: onSuccessFade,
    error: function() { onSuccessFade(); }
  });

  return false;
}

function grvLoadTab() {
  var queryStr = grvQueryString();
  var tab = $grv(this);
  var tabId = tab.attr('data-panel-id');
  var deferredArticlesUrl = grvNoFinalSlashUrl + '/tab/' + tabId + queryStr;
  var targetPanel = $grv('#mostPopularTab_panel_' + tabId);
  targetPanel.find('.spinner').show().siblings('.panel_content').hide();
  $grv.ajax({
    url: deferredArticlesUrl,
    timeout: 1000 * 10,
    success: function(html) {
      targetPanel.find('.spinner').hide().siblings('.panel_content').html(html).show();
      grvBindArticleHandlers(targetPanel);
    },
    error: function(xhr, textStatus, errorThrown) {
      targetPanel.find('.spinner').hide().siblings('.panel_content').html("<p>Sorry, there are no posts available right now.</p><p>Please try again later.</p>").show();
      tab.one('click', function() { grvLoadTab.call(tab); });
      $grv.post(grvNoFinalSlashUrl + '/log', { desc: textStatus + ': ' + errorThrown });
    }
  });
}

$grv(document).ready(function() {
  grvBindArticleHandlers($grv('body'));

  $grv('.tab').click(function() {
    var tab = $grv(this);
    tab.addClass('selectedTab').siblings().removeClass('selectedTab');
    $grv('#mostPopularTab_panel_' + tab.attr('data-panel-id')).show().siblings('.panel').hide();
    return false;
  });

  $grv('.deferred').one('click', grvLoadTab);

  if (grvBeaconUrl) {
    $grv.getScript(grvBeaconUrl);
  }
});
