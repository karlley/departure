// gem turbolinks でready イベントが発火しないのでturbolinks:load
$(document).on('turbolinks:load', function () {
  // 国名のセレクトボックスのoption 作成
  function appendOption(country) {
    var html = `<option value="${country.id}">${country.country_name}</option>`;
    return html;
  }
  // 国名のセレクトボックス用HTML
  function appendCountriesSelectBox(insertHTML) {
    var countriesSelectBoxHtml = '';
    countriesSelectBoxHtml = `<div class="form-group" id="country_select_box">
                                <label for="destination_country_id">国</label>
                                <span class="input-need"> *必須</span>
                                <select class="form-control" id="destination_country_id" name="destination[country_id]">
                                  ${insertHTML}
                                </select>
                              </div>`;
    $('#destination_country').append(countriesSelectBoxHtml);
  }

  // 地域選択後にAjax で国名を取得
  $('#destination_region_id').on('change', function () {
    var selectedRegion = document.getElementById('destination_region_id').value;
    // 初期値以外を選択
    if (selectedRegion != "") {
      $.ajax({
        url: 'get_region_countries',
        type: 'GET',
        data: { region_id: selectedRegion },
        dataType: 'json'
      })
        .done(function (countries) {
          // 地域名の再選択で国名のセレクトボックスを削除
          $('#country_select_box').remove();
          var insertHTML = '';
          countries.forEach(function (country) {
            insertHTML += appendOption(country);
          });
          appendCountriesSelectBox(insertHTML);
        })
        .fail(function () {
          // 国名の取得に失敗した場合
          alert('国名の取得に失敗しました');
        })
    } else {
      // 地域名が初期値に戻ると国名のセレクトボックスを削除
      $('#country_select_box').remove();
    }
  });
});
