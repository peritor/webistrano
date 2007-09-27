require File.dirname(__FILE__) + '/test_helper'

class MultipleSelectTest < Test::Unit::TestCase #:nodoc:
  include FightTheMelons::Helpers::FormMultipleSelectHelper
  
  fixtures :nodes, :fathers, :sons
  
  # Have to fake the default static variables because they jump from one test to
  # another. Yes, this is bad bad bad coding.
  def setup
    FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.outer_class = nil
    FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.inner_class = nil
    FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.level_class = nil
    FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.alternate_class = 'alt'
    FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.alternate = false
    FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.position = :right
  end
  
  def test_cfms_empty
    assert_equal "", checkboxes_for_multiple_select('name', [])
  end
  
  def test_cfms_one_item
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test'])
<li><input id="nametest" name="name[]" type="checkbox" value="test" /><label for="nametest">test</label></li>
END
  end
  
  def test_cfms_two_items
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test1', 'test2'])
<li><input id="nametest1" name="name[]" type="checkbox" value="test1" /><label for="nametest1">test1</label></li>
<li><input id="nametest2" name="name[]" type="checkbox" value="test2" /><label for="nametest2">test2</label></li>
END
  end
  
  def test_cfms_array_not_strings
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', [1, 2])
<li><input id="name1" name="name[]" type="checkbox" value="1" /><label for="name1">1</label></li>
<li><input id="name2" name="name[]" type="checkbox" value="2" /><label for="name2">2</label></li>
END
      
  end
  
  def test_cfms_text_value_array
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', [['first test', 1], ['second test', 2]])
<li><input id="name1" name="name[]" type="checkbox" value="1" /><label for="name1">first test</label></li>
<li><input id="name2" name="name[]" type="checkbox" value="2" /><label for="name2">second test</label></li>
END
  end
  
  def test_cfms_hash
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', {'first test' => 1, 'second test' => 2})
<li><input id="name2" name="name[]" type="checkbox" value="2" /><label for="name2">second test</label></li>
<li><input id="name1" name="name[]" type="checkbox" value="1" /><label for="name1">first test</label></li>
END
  end
  
  def test_cfms_array_with_selected
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', [1, 2], [1])
<li><input checked="checked" id="name1" name="name[]" type="checkbox" value="1" /><label for="name1">1</label></li>
<li><input id="name2" name="name[]" type="checkbox" value="2" /><label for="name2">2</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', [1, 2], [2])
<li><input id="name1" name="name[]" type="checkbox" value="1" /><label for="name1">1</label></li>
<li><input checked="checked" id="name2" name="name[]" type="checkbox" value="2" /><label for="name2">2</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', [1, 2], [1,2])
<li><input checked="checked" id="name1" name="name[]" type="checkbox" value="1" /><label for="name1">1</label></li>
<li><input checked="checked" id="name2" name="name[]" type="checkbox" value="2" /><label for="name2">2</label></li>
END
  end
  
  def test_cfms_text_value_array_with_selected
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', [['first test', 1], ['second test', 2]], [1])
<li><input checked="checked" id="name1" name="name[]" type="checkbox" value="1" /><label for="name1">first test</label></li>
<li><input id="name2" name="name[]" type="checkbox" value="2" /><label for="name2">second test</label></li>
END
      
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', [['first test', 1], ['second test', 2]], [2])
<li><input id="name1" name="name[]" type="checkbox" value="1" /><label for="name1">first test</label></li>
<li><input checked="checked" id="name2" name="name[]" type="checkbox" value="2" /><label for="name2">second test</label></li>
END
      
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', [['first test', 1], ['second test', 2]], [1,2])
<li><input checked="checked" id="name1" name="name[]" type="checkbox" value="1" /><label for="name1">first test</label></li>
<li><input checked="checked" id="name2" name="name[]" type="checkbox" value="2" /><label for="name2">second test</label></li>
END
  end
  
  def test_cfms_hash_with_selected
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', { 'Spain' => 'esp', 'England' => 'eng' }, ['esp'])
<li><input checked="checked" id="nameesp" name="name[]" type="checkbox" value="esp" /><label for="nameesp">Spain</label></li>
<li><input id="nameeng" name="name[]" type="checkbox" value="eng" /><label for="nameeng">England</label></li>
END
      
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', { 'Spain' => 'esp', 'England' => 'eng' }, ['eng'])
<li><input id="nameesp" name="name[]" type="checkbox" value="esp" /><label for="nameesp">Spain</label></li>
<li><input checked="checked" id="nameeng" name="name[]" type="checkbox" value="eng" /><label for="nameeng">England</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', { 'Spain' => 'esp', 'England' => 'eng' }, ['esp', 'eng'])
<li><input checked="checked" id="nameesp" name="name[]" type="checkbox" value="esp" /><label for="nameesp">Spain</label></li>
<li><input checked="checked" id="nameeng" name="name[]" type="checkbox" value="eng" /><label for="nameeng">England</label></li>
END
  end
  
  def test_cfms_position
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test'], [], :position => :right)
<li><input id="nametest" name="name[]" type="checkbox" value="test" /><label for="nametest">test</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test'], [], :position => :left)
<li><label for="nametest">test</label><input id="nametest" name="name[]" type="checkbox" value="test" /></li>
END
  end
  
  def test_cfms_position_variable
    FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.position = :right
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test'], [])
<li><input id="nametest" name="name[]" type="checkbox" value="test" /><label for="nametest">test</label></li>
END
    
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test'], [], :position => :left)
<li><label for="nametest">test</label><input id="nametest" name="name[]" type="checkbox" value="test" /></li>
END
  end
  
  def test_cfms_inner_class
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test'], [], :inner_class => 'testclass')
<li class="testclass"><input id="nametest" name="name[]" type="checkbox" value="test" /><label for="nametest">test</label></li>
END
  end
  
  def test_cfms_inner_class_variable
    FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.inner_class = 'classtest'
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test'], [])
<li class="classtest"><input id="nametest" name="name[]" type="checkbox" value="test" /><label for="nametest">test</label></li>
END
    
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test'], [], :inner_class => 'testclass')
<li class="testclass"><input id="nametest" name="name[]" type="checkbox" value="test" /><label for="nametest">test</label></li>
END
  end
  
  def test_cfms_alternate
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test1', 'test2'], [], :alternate => true)
<li><input id="nametest1" name="name[]" type="checkbox" value="test1" /><label for="nametest1">test1</label></li>
<li class="alt"><input id="nametest2" name="name[]" type="checkbox" value="test2" /><label for="nametest2">test2</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test1', 'test2'], [], :alternate => true, :inner_class => 'testclass')
<li class="testclass"><input id="nametest1" name="name[]" type="checkbox" value="test1" /><label for="nametest1">test1</label></li>
<li class="testclass alt"><input id="nametest2" name="name[]" type="checkbox" value="test2" /><label for="nametest2">test2</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test1', 'test2'], [], :alternate => true, :alternate_class => 'alternative')
<li><input id="nametest1" name="name[]" type="checkbox" value="test1" /><label for="nametest1">test1</label></li>
<li class="alternative"><input id="nametest2" name="name[]" type="checkbox" value="test2" /><label for="nametest2">test2</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test1', 'test2'], [], :alternate => true, :initial_alternate => false)
<li><input id="nametest1" name="name[]" type="checkbox" value="test1" /><label for="nametest1">test1</label></li>
<li class="alt"><input id="nametest2" name="name[]" type="checkbox" value="test2" /><label for="nametest2">test2</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test1', 'test2'], [], :alternate => true, :initial_alternate => true)
<li class="alt"><input id="nametest1" name="name[]" type="checkbox" value="test1" /><label for="nametest1">test1</label></li>
<li><input id="nametest2" name="name[]" type="checkbox" value="test2" /><label for="nametest2">test2</label></li>
END
  end
  
  def test_cfms_alternate_variable
    FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.alternate = true
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test1', 'test2'], [])
<li><input id="nametest1" name="name[]" type="checkbox" value="test1" /><label for="nametest1">test1</label></li>
<li class="alt"><input id="nametest2" name="name[]" type="checkbox" value="test2" /><label for="nametest2">test2</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test1', 'test2'], [], :alternate => false)
<li><input id="nametest1" name="name[]" type="checkbox" value="test1" /><label for="nametest1">test1</label></li>
<li><input id="nametest2" name="name[]" type="checkbox" value="test2" /><label for="nametest2">test2</label></li>
END
  end
  
  def test_cfms_alternate_class_variable
    FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.alternate_class = 'other'
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test1', 'test2'], [], :alternate => true)
<li><input id="nametest1" name="name[]" type="checkbox" value="test1" /><label for="nametest1">test1</label></li>
<li class="other"><input id="nametest2" name="name[]" type="checkbox" value="test2" /><label for="nametest2">test2</label></li>
END
    
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', ['test1', 'test2'], [], :alternate => true, :alternate_class => 'alternative')
<li><input id="nametest1" name="name[]" type="checkbox" value="test1" /><label for="nametest1">test1</label></li>
<li class="alternative"><input id="nametest2" name="name[]" type="checkbox" value="test2" /><label for="nametest2">test2</label></li>
END
  end
  
  def test_cfms_disabled
    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', [1, 2], [], :disabled => false)
<li><input id="name1" name="name[]" type="checkbox" value="1" /><label for="name1">1</label></li>
<li><input id="name2" name="name[]" type="checkbox" value="2" /><label for="name2">2</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', [1, 2], [], :disabled => true)
<li><input disabled="disabled" id="name1" name="name[]" type="checkbox" value="1" /><label for="name1">1</label></li>
<li><input disabled="disabled" id="name2" name="name[]" type="checkbox" value="2" /><label for="name2">2</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_for_multiple_select('name', [1, 2], [], :disabled => [1])
<li><input disabled="disabled" id="name1" name="name[]" type="checkbox" value="1" /><label for="name1">1</label></li>
<li><input id="name2" name="name[]" type="checkbox" value="2" /><label for="name2">2</label></li>
END
  end
  
  def test_cfcfms
    assert_dom_equal <<END.strip, checkboxes_from_collection_for_multiple_select('name', Node.find_all_by_parent_id(1), :id, :name)
<li><input id="name2" name="name[]" type="checkbox" value="2" /><label for="name2">Node 1</label></li>
<li><input id="name3" name="name[]" type="checkbox" value="3" /><label for="name3">Node 2</label></li>
<li><input id="name4" name="name[]" type="checkbox" value="4" /><label for="name4">Node 3</label></li>
END

    assert_dom_equal "",
      checkboxes_from_collection_for_multiple_select('name', Node.find_all_by_parent_id(33), :id, :name) # id 33 doesn't exist nor have children
  end
  
  def test_cfcms_with_selected
    assert_dom_equal <<END.strip, checkboxes_from_collection_for_multiple_select('name', Node.find_all_by_parent_id(1), :id, :name, [2, 4])
<li><input checked="checked" id="name2" name="name[]" type="checkbox" value="2" /><label for="name2">Node 1</label></li>
<li><input id="name3" name="name[]" type="checkbox" value="3" /><label for="name3">Node 2</label></li>
<li><input checked="checked" id="name4" name="name[]" type="checkbox" value="4" /><label for="name4">Node 3</label></li>
END
  end
  
  def test_ms
    @f = Father.new
    assert_dom_equal <<END.strip, multiple_select('f', 'method_for_test', ['test'])
<ul><li><input id="f_method_for_test_test" name="f[method_for_test][]" type="checkbox" value="test" /><label for="f_method_for_test_test">test</label></li></ul>
<input name="f[method_for_test][]" type="hidden" value="" />
END
  end

  def test_ms_with_outer_class
    @f = Father.new
    assert_dom_equal <<END.strip, multiple_select('f', 'method_for_test', ['test'], :outer_class => 'test_class')
<ul class="test_class"><li><input id="f_method_for_test_test" name="f[method_for_test][]" type="checkbox" value="test" /><label for="f_method_for_test_test">test</label></li></ul>
<input name="f[method_for_test][]" type="hidden" value="" />
END
  end

  def test_ms_selected
    @f = Father.new
    assert_dom_equal <<END.strip, multiple_select('f', 'method_for_test_selected', ['test'])
<ul><li><input checked="checked" id="f_method_for_test_selected_test" name="f[method_for_test_selected][]" type="checkbox" value="test" /><label for="f_method_for_test_selected_test">test</label></li></ul>
<input name="f[method_for_test_selected][]" type="hidden" value="" />
END
  end
  
  def test_ms_empty
    @f = Father.new
    assert_dom_equal <<END.strip, multiple_select('f', 'method_for_test', [])
<ul></ul>
<input name="f[method_for_test][]" type="hidden" value="" />
END
  end
  
  def test_mst
    assert_dom_equal <<END.strip, multiple_select_tag('f', ['test'])
<ul><li><input id="ftest" name="f[]" type="checkbox" value="test" /><label for="ftest">test</label></li></ul>
<input name="f[]" type="hidden" value="" />
END
  end

  def test_mst_with_outer_class
    assert_dom_equal <<END.strip, multiple_select_tag('f', ['test'], :outer_class => 'test_class')
<ul class="test_class"><li><input id="ftest" name="f[]" type="checkbox" value="test" /><label for="ftest">test</label></li></ul>
<input name="f[]" type="hidden" value="" />
END
  end

  def test_mst_with_selected_items
    assert_dom_equal <<END.strip, multiple_select_tag('f', ['test'], :selected_items => ['test'])
<ul><li><input checked="checked" id="ftest" name="f[]" type="checkbox" value="test" /><label for="ftest">test</label></li></ul>
<input name="f[]" type="hidden" value="" />
END
  end
  
  def test_mst_empty
    assert_dom_equal <<END.strip, multiple_select_tag('f', [])
<ul></ul>
<input name="f[]" type="hidden" value="" />
END
  end
  
  def test_ms_selected_items
    @n = Node.new
    assert_dom_equal <<END.strip, multiple_select('n', 'selected_some', [1, 2], :selected_items => [2] )
<ul><li><input id="n_selected_some_1" name="n[selected_some][]" type="checkbox" value="1" /><label for="n_selected_some_1">1</label></li>
<li><input id="n_selected_some_2" name="n[selected_some][]" type="checkbox" value="2" checked="checked" /><label for="n_selected_some_2">2</label></li></ul>
<input name="n[selected_some][]" type="hidden" value="" />
END
  end
  
  def test_ms_selected_items_nil
    @n = Node.new
    assert_dom_equal <<END.strip, multiple_select('n', 'selected_some', [1, 2], :selected_items => nil )    
<ul><li><input id="n_selected_some_1" name="n[selected_some][]" type="checkbox" value="1" /><label for="n_selected_some_1">1</label></li>
<li><input id="n_selected_some_2" name="n[selected_some][]" type="checkbox" value="2" /><label for="n_selected_some_2">2</label></li></ul>
<input name="n[selected_some][]" type="hidden" value="" />
END
  end
  
  def test_ms_outer_class_variable
    @f = Father.new
    FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.outer_class = 'classtest'
    assert_dom_equal <<END.strip, multiple_select('f', 'method_for_test', ['test'])
<ul class="classtest"><li><input id="f_method_for_test_test" name="f[method_for_test][]" type="checkbox" value="test" /><label for="f_method_for_test_test">test</label></li></ul>
<input name="f[method_for_test][]" type="hidden" value="" />
END

    assert_dom_equal <<END.strip, multiple_select('f', 'method_for_test', ['test'], :outer_class => 'testclass')
<ul class="testclass"><li><input id="f_method_for_test_test" name="f[method_for_test][]" type="checkbox" value="test" /><label for="f_method_for_test_test">test</label></li></ul>
<input name="f[method_for_test][]" type="hidden" value="" />
END
  end
    
  def test_ms_nil_value
    @n = Node.new
    assert_dom_equal <<END.strip, multiple_select('n', 'selected_nil', {'item1' => 'value1', 'item2' => 'value2'} )
<ul><li><input id="n_selected_nil_value1" name="n[selected_nil][]" type="checkbox" value="value1" /><label for="n_selected_nil_value1">item1</label></li>
<li><input id="n_selected_nil_value2" name="n[selected_nil][]" type="checkbox" value="value2" /><label for="n_selected_nil_value2">item2</label></li></ul>
<input name="n[selected_nil][]" type="hidden" value="" />
END
  end
  
  def test_cms
    Father.class_eval 'has_many :sons'
    Son.class_eval 'belongs_to :father'
    
    @f = Father.new
    @f.son_ids = []
    
    assert_dom_equal <<END.strip, collection_multiple_select('f', 'son_ids', Son.find(:all), :id, :name)
<ul><li><input id="f_son_ids_1" name="f[son_ids][]" type="checkbox" value="1" /><label for="f_son_ids_1">Son 1</label></li>
<li><input id="f_son_ids_2" name="f[son_ids][]" type="checkbox" value="2" /><label for="f_son_ids_2">Son 2</label></li>
<li><input id="f_son_ids_3" name="f[son_ids][]" type="checkbox" value="3" /><label for="f_son_ids_3">Son 3</label></li>
<li><input id="f_son_ids_4" name="f[son_ids][]" type="checkbox" value="4" /><label for="f_son_ids_4">Son 4</label></li>
<li><input id="f_son_ids_5" name="f[son_ids][]" type="checkbox" value="5" /><label for="f_son_ids_5">Son 5</label></li>
<li><input id="f_son_ids_6" name="f[son_ids][]" type="checkbox" value="6" /><label for="f_son_ids_6">Son 6</label></li>
<li><input id="f_son_ids_7" name="f[son_ids][]" type="checkbox" value="7" /><label for="f_son_ids_7">Son 7</label></li></ul>
<input name="f[son_ids][]" type="hidden" value="" />
END
  end
  
  def test_cms_with_outer_class
    Father.class_eval 'has_many :sons'
    Son.class_eval 'belongs_to :father'
    
    @f = Father.new
    @f.son_ids = []
    
    assert_dom_equal <<END.strip, collection_multiple_select('f', 'son_ids', Son.find(:all), :id, :name, :outer_class => 'test_class')
<ul class="test_class"><li><input id="f_son_ids_1" name="f[son_ids][]" type="checkbox" value="1" /><label for="f_son_ids_1">Son 1</label></li>
<li><input id="f_son_ids_2" name="f[son_ids][]" type="checkbox" value="2" /><label for="f_son_ids_2">Son 2</label></li>
<li><input id="f_son_ids_3" name="f[son_ids][]" type="checkbox" value="3" /><label for="f_son_ids_3">Son 3</label></li>
<li><input id="f_son_ids_4" name="f[son_ids][]" type="checkbox" value="4" /><label for="f_son_ids_4">Son 4</label></li>
<li><input id="f_son_ids_5" name="f[son_ids][]" type="checkbox" value="5" /><label for="f_son_ids_5">Son 5</label></li>
<li><input id="f_son_ids_6" name="f[son_ids][]" type="checkbox" value="6" /><label for="f_son_ids_6">Son 6</label></li>
<li><input id="f_son_ids_7" name="f[son_ids][]" type="checkbox" value="7" /><label for="f_son_ids_7">Son 7</label></li></ul>
<input name="f[son_ids][]" type="hidden" value="" />
END
  end
  
  def test_cms_with_value
    Father.class_eval 'has_many :sons'
    Son.class_eval 'belongs_to :father'
    
    @f = Father.new
    @f.son_ids = [4, 5, 6]
    
    assert_dom_equal <<END.strip, collection_multiple_select('f', 'son_ids', Son.find(:all), :id, :name)
<ul><li><input id="f_son_ids_1" name="f[son_ids][]" type="checkbox" value="1" /><label for="f_son_ids_1">Son 1</label></li>
<li><input id="f_son_ids_2" name="f[son_ids][]" type="checkbox" value="2" /><label for="f_son_ids_2">Son 2</label></li>
<li><input id="f_son_ids_3" name="f[son_ids][]" type="checkbox" value="3" /><label for="f_son_ids_3">Son 3</label></li>
<li><input checked="checked" id="f_son_ids_4" name="f[son_ids][]" type="checkbox" value="4" /><label for="f_son_ids_4">Son 4</label></li>
<li><input checked="checked" id="f_son_ids_5" name="f[son_ids][]" type="checkbox" value="5" /><label for="f_son_ids_5">Son 5</label></li>
<li><input checked="checked" id="f_son_ids_6" name="f[son_ids][]" type="checkbox" value="6" /><label for="f_son_ids_6">Son 6</label></li>
<li><input id="f_son_ids_7" name="f[son_ids][]" type="checkbox" value="7" /><label for="f_son_ids_7">Son 7</label></li></ul>
<input name="f[son_ids][]" type="hidden" value="" />
END
  end
  
  def test_cms_without_items
    Father.class_eval 'has_many :sons'
    Son.class_eval 'belongs_to :father'
    
    @f = Father.new
    @f.son_ids = []
    
     assert_dom_equal <<END.strip, collection_multiple_select('f', 'son_ids', [], :id, :name)
<ul></ul>
<input name="f[son_ids][]" type="hidden" value="" />
END
  end
  
  def test_cmst
    assert_dom_equal <<END.strip, collection_multiple_select_tag('sons', Son.find(:all), :id, :name)
<ul><li><input id="sons1" name="sons[]" type="checkbox" value="1" /><label for="sons1">Son 1</label></li>
<li><input id="sons2" name="sons[]" type="checkbox" value="2" /><label for="sons2">Son 2</label></li>
<li><input id="sons3" name="sons[]" type="checkbox" value="3" /><label for="sons3">Son 3</label></li>
<li><input id="sons4" name="sons[]" type="checkbox" value="4" /><label for="sons4">Son 4</label></li>
<li><input id="sons5" name="sons[]" type="checkbox" value="5" /><label for="sons5">Son 5</label></li>
<li><input id="sons6" name="sons[]" type="checkbox" value="6" /><label for="sons6">Son 6</label></li>
<li><input id="sons7" name="sons[]" type="checkbox" value="7" /><label for="sons7">Son 7</label></li></ul>
<input name="sons[]" type="hidden" value="" />
END
  end

  def test_cmst_with_outer_class
    assert_dom_equal <<END.strip, collection_multiple_select_tag('sons', Son.find(:all), :id, :name, :outer_class => 'test_class')
<ul class="test_class"><li><input id="sons1" name="sons[]" type="checkbox" value="1" /><label for="sons1">Son 1</label></li>
<li><input id="sons2" name="sons[]" type="checkbox" value="2" /><label for="sons2">Son 2</label></li>
<li><input id="sons3" name="sons[]" type="checkbox" value="3" /><label for="sons3">Son 3</label></li>
<li><input id="sons4" name="sons[]" type="checkbox" value="4" /><label for="sons4">Son 4</label></li>
<li><input id="sons5" name="sons[]" type="checkbox" value="5" /><label for="sons5">Son 5</label></li>
<li><input id="sons6" name="sons[]" type="checkbox" value="6" /><label for="sons6">Son 6</label></li>
<li><input id="sons7" name="sons[]" type="checkbox" value="7" /><label for="sons7">Son 7</label></li></ul>
<input name="sons[]" type="hidden" value="" />
END
  end

  def test_cmst_with_selected_items
    assert_dom_equal <<END.strip, collection_multiple_select_tag('sons', Son.find(:all), :id, :name, :selected_items => [4, 5, 6])
<ul><li><input id="sons1" name="sons[]" type="checkbox" value="1" /><label for="sons1">Son 1</label></li>
<li><input id="sons2" name="sons[]" type="checkbox" value="2" /><label for="sons2">Son 2</label></li>
<li><input id="sons3" name="sons[]" type="checkbox" value="3" /><label for="sons3">Son 3</label></li>
<li><input checked="checked" id="sons4" name="sons[]" type="checkbox" value="4" /><label for="sons4">Son 4</label></li>
<li><input checked="checked" id="sons5" name="sons[]" type="checkbox" value="5" /><label for="sons5">Son 5</label></li>
<li><input checked="checked" id="sons6" name="sons[]" type="checkbox" value="6" /><label for="sons6">Son 6</label></li>
<li><input id="sons7" name="sons[]" type="checkbox" value="7" /><label for="sons7">Son 7</label></li></ul>
<input name="sons[]" type="hidden" value="" />
END
  end

  def test_cmst_without_items
     assert_dom_equal <<END.strip, collection_multiple_select_tag('sons', [], :id, :name)
<ul></ul>
<input name="sons[]" type="hidden" value="" />
END
  end
  
  def test_cms_selected_items
    Father.class_eval 'has_many :sons'
    Son.class_eval 'belongs_to :father'
    
    @f = Father.new
    @f.son_ids = []
    
    assert_dom_equal <<END.strip, collection_multiple_select('f', 'son_ids', Son.find(:all), :id, :name, :selected_items => [1, 2, 3])
<ul><li><input id="f_son_ids_1" name="f[son_ids][]" type="checkbox" value="1" checked="checked" /><label for="f_son_ids_1">Son 1</label></li>
<li><input id="f_son_ids_2" name="f[son_ids][]" type="checkbox" value="2" checked="checked" /><label for="f_son_ids_2">Son 2</label></li>
<li><input id="f_son_ids_3" name="f[son_ids][]" type="checkbox" value="3" checked="checked" /><label for="f_son_ids_3">Son 3</label></li>
<li><input id="f_son_ids_4" name="f[son_ids][]" type="checkbox" value="4" /><label for="f_son_ids_4">Son 4</label></li>
<li><input id="f_son_ids_5" name="f[son_ids][]" type="checkbox" value="5" /><label for="f_son_ids_5">Son 5</label></li>
<li><input id="f_son_ids_6" name="f[son_ids][]" type="checkbox" value="6" /><label for="f_son_ids_6">Son 6</label></li>
<li><input id="f_son_ids_7" name="f[son_ids][]" type="checkbox" value="7" /><label for="f_son_ids_7">Son 7</label></li></ul>
<input name="f[son_ids][]" type="hidden" value="" />
END
  end
  
  def test_cms_selected_items_nil
    Father.class_eval 'has_many :sons'
    Son.class_eval 'belongs_to :father'
    
    @f = Father.new
    @f.son_ids = []
    
    assert_dom_equal <<END.strip, collection_multiple_select('f', 'son_ids', Son.find(:all), :id, :name, :selected_items => nil)
<ul><li><input id="f_son_ids_1" name="f[son_ids][]" type="checkbox" value="1" /><label for="f_son_ids_1">Son 1</label></li>
<li><input id="f_son_ids_2" name="f[son_ids][]" type="checkbox" value="2" /><label for="f_son_ids_2">Son 2</label></li>
<li><input id="f_son_ids_3" name="f[son_ids][]" type="checkbox" value="3" /><label for="f_son_ids_3">Son 3</label></li>
<li><input id="f_son_ids_4" name="f[son_ids][]" type="checkbox" value="4" /><label for="f_son_ids_4">Son 4</label></li>
<li><input id="f_son_ids_5" name="f[son_ids][]" type="checkbox" value="5" /><label for="f_son_ids_5">Son 5</label></li>
<li><input id="f_son_ids_6" name="f[son_ids][]" type="checkbox" value="6" /><label for="f_son_ids_6">Son 6</label></li>
<li><input id="f_son_ids_7" name="f[son_ids][]" type="checkbox" value="7" /><label for="f_son_ids_7">Son 7</label></li></ul>
<input name="f[son_ids][]" type="hidden" value="" />
END
  end
  
  def test_tms_selected_none
    @n = Node.new
    assert_dom_equal <<END.strip, tree_multiple_select('n', 'selected_none', nodes(:n32).children, :id, :name)
<ul><li><input id="n_selected_none_11" name="n[selected_none][]" type="checkbox" value="11" /><label for="n_selected_none_11">Node 3.2.1</label></li>
<li><input id="n_selected_none_12" name="n[selected_none][]" type="checkbox" value="12" /><label for="n_selected_none_12">Node 3.2.2</label></li></ul>
<input name="n[selected_none][]" type="hidden" value="" />
END
  end

  def test_tms_with_outer_class
    @n = Node.new
    assert_dom_equal <<END.strip, tree_multiple_select('n', 'selected_none', nodes(:n32).children, :id, :name, :outer_class => 'test_class')
<ul class="test_class"><li><input id="n_selected_none_11" name="n[selected_none][]" type="checkbox" value="11" /><label for="n_selected_none_11">Node 3.2.1</label></li>
<li><input id="n_selected_none_12" name="n[selected_none][]" type="checkbox" value="12" /><label for="n_selected_none_12">Node 3.2.2</label></li></ul>
<input name="n[selected_none][]" type="hidden" value="" />
END
  end
  
  def test_tms_selected_some
    @n = Node.new
    assert_dom_equal <<END.strip, tree_multiple_select('n', 'selected_some', nodes(:n32).children, :id, :name)
<ul><li><input id="n_selected_some_11" name="n[selected_some][]" type="checkbox" value="11" /><label for="n_selected_some_11">Node 3.2.1</label></li>
<li><input checked="checked" id="n_selected_some_12" name="n[selected_some][]" type="checkbox" value="12" /><label for="n_selected_some_12">Node 3.2.2</label></li></ul>
<input name="n[selected_some][]" type="hidden" value="" />
END
  end
  
  def test_tms_without_items
    @n = Node.new
    assert_dom_equal <<END.strip, tree_multiple_select('n', 'selected_some', nodes(:n33).children, :id, :name)
<ul></ul>
<input name="n[selected_some][]" type="hidden" value="" />
END
  end
  
  def test_tmst
    assert_dom_equal <<END.strip, tree_multiple_select_tag('n', nodes(:n32).children, :id, :name)
<ul><li><input id="n11" name="n[]" type="checkbox" value="11" /><label for="n11">Node 3.2.1</label></li>
<li><input id="n12" name="n[]" type="checkbox" value="12" /><label for="n12">Node 3.2.2</label></li></ul>
<input name="n[]" type="hidden" value="" />
END
  end

  def test_tmst_with_outer_class
    assert_dom_equal <<END.strip, tree_multiple_select_tag('n', nodes(:n32).children, :id, :name, :outer_class => 'test_class')
<ul class="test_class"><li><input id="n11" name="n[]" type="checkbox" value="11" /><label for="n11">Node 3.2.1</label></li>
<li><input id="n12" name="n[]" type="checkbox" value="12" /><label for="n12">Node 3.2.2</label></li></ul>
<input name="n[]" type="hidden" value="" />
END
  end

  def test_tmst_with_selected_items
    assert_dom_equal <<END.strip, tree_multiple_select_tag('n', nodes(:n32).children, :id, :name, :selected_items => [12])
<ul><li><input id="n11" name="n[]" type="checkbox" value="11" /><label for="n11">Node 3.2.1</label></li>
<li><input checked="checked" id="n12" name="n[]" type="checkbox" value="12" /><label for="n12">Node 3.2.2</label></li></ul>
<input name="n[]" type="hidden" value="" />
END
  end

  def test_tmst_without_items
    assert_dom_equal <<END.strip, tree_multiple_select_tag('n', nodes(:n33).children, :id, :name)
<ul></ul>
<input name="n[]" type="hidden" value="" />
END
  end
  
  def test_tms_selected_items
    @n = Node.new
    assert_dom_equal <<END.strip, tree_multiple_select('n', 'selected_none', nodes(:n32).children, :id, :name, :selected_items => [11])
<ul><li><input id="n_selected_none_11" name="n[selected_none][]" type="checkbox" value="11" checked="checked" /><label for="n_selected_none_11">Node 3.2.1</label></li>
<li><input id="n_selected_none_12" name="n[selected_none][]" type="checkbox" value="12" /><label for="n_selected_none_12">Node 3.2.2</label></li></ul>
<input name="n[selected_none][]" type="hidden" value="" />
END
  end
  
  def test_tms_selected_items_nil
    @n = Node.new
    assert_dom_equal <<END.strip, tree_multiple_select('n', 'selected_none', nodes(:n32).children, :id, :name, :selected_items => nil)
<ul><li><input id="n_selected_none_11" name="n[selected_none][]" type="checkbox" value="11" /><label for="n_selected_none_11">Node 3.2.1</label></li>
<li><input id="n_selected_none_12" name="n[selected_none][]" type="checkbox" value="12" /><label for="n_selected_none_12">Node 3.2.2</label></li></ul>
<input name="n[selected_none][]" type="hidden" value="" />
END
  end
    
  def test_cftfms
    assert_dom_equal <<END.strip, checkboxes_from_tree_for_multiple_select('name', nodes(:n3).children, :id, :name)
<li><input id="name8" name="name[]" type="checkbox" value="8" /><label for="name8">Node 3.1</label></li>
<li><input id="name9" name="name[]" type="checkbox" value="9" /><label for="name9">Node 3.2</label>\n<ul><li><input id="name11" name="name[]" type="checkbox" value="11" /><label for="name11">Node 3.2.1</label></li>
<li><input id="name12" name="name[]" type="checkbox" value="12" /><label for="name12">Node 3.2.2</label></li></ul></li>
<li><input id="name10" name="name[]" type="checkbox" value="10" /><label for="name10">Node 3.3</label></li>
END
  end
  
  def test_cftfms_depth
    assert_dom_equal <<END.strip, checkboxes_from_tree_for_multiple_select('name', nodes(:n3).children, :id, :name, [], :depth => 1), "Depth 1"
<li><input id="name8" name="name[]" type="checkbox" value="8" /><label for="name8">Node 3.1</label></li>
<li><input id="name9" name="name[]" type="checkbox" value="9" /><label for="name9">Node 3.2</label>\n<ul><li><input id="name11" name="name[]" type="checkbox" value="11" /><label for="name11">Node 3.2.1</label></li>
<li><input id="name12" name="name[]" type="checkbox" value="12" /><label for="name12">Node 3.2.2</label></li></ul></li>
<li><input id="name10" name="name[]" type="checkbox" value="10" /><label for="name10">Node 3.3</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_from_tree_for_multiple_select('name', nodes(:n3).children, :id, :name, [], :depth => 2), "Depth 2"
<li><input id="name8" name="name[]" type="checkbox" value="8" /><label for="name8">Node 3.1</label></li>
<li><input id="name9" name="name[]" type="checkbox" value="9" /><label for="name9">Node 3.2</label>\n<ul><li><input id="name11" name="name[]" type="checkbox" value="11" /><label for="name11">Node 3.2.1</label></li>
<li><input id="name12" name="name[]" type="checkbox" value="12" /><label for="name12">Node 3.2.2</label></li></ul></li>
<li><input id="name10" name="name[]" type="checkbox" value="10" /><label for="name10">Node 3.3</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_from_tree_for_multiple_select('name', nodes(:n3).children, :id, :name, [], :depth => 0), "Depth 0"
<li><input id="name8" name="name[]" type="checkbox" value="8" /><label for="name8">Node 3.1</label></li>
<li><input id="name9" name="name[]" type="checkbox" value="9" /><label for="name9">Node 3.2</label></li>
<li><input id="name10" name="name[]" type="checkbox" value="10" /><label for="name10">Node 3.3</label></li>
END
  end
  
  def test_cftfms_inner_class
    assert_dom_equal <<END.strip, checkboxes_from_tree_for_multiple_select('name', nodes(:n3).children, :id, :name, [], :inner_class => 'testclass')
<li class="testclass"><input id="name8" name="name[]" type="checkbox" value="8" /><label for="name8">Node 3.1</label></li>
<li class="testclass"><input id="name9" name="name[]" type="checkbox" value="9" /><label for="name9">Node 3.2</label>\n<ul><li class="testclass"><input id="name11" name="name[]" type="checkbox" value="11" /><label for="name11">Node 3.2.1</label></li>
<li class="testclass"><input id="name12" name="name[]" type="checkbox" value="12" /><label for="name12">Node 3.2.2</label></li></ul></li>
<li class="testclass"><input id="name10" name="name[]" type="checkbox" value="10" /><label for="name10">Node 3.3</label></li>
END
  end
  
  def test_cftfms_level_class
    assert_dom_equal <<END.strip, checkboxes_from_tree_for_multiple_select('name', nodes(:n3).children, :id, :name, [], :level_class => 'level'), "With level class"
<li class="level0"><input id="name8" name="name[]" type="checkbox" value="8" /><label for="name8">Node 3.1</label></li>
<li class="level0"><input id="name9" name="name[]" type="checkbox" value="9" /><label for="name9">Node 3.2</label>\n<ul><li class="level1"><input id="name11" name="name[]" type="checkbox" value="11" /><label for="name11">Node 3.2.1</label></li>
<li class="level1"><input id="name12" name="name[]" type="checkbox" value="12" /><label for="name12">Node 3.2.2</label></li></ul></li>
<li class="level0"><input id="name10" name="name[]" type="checkbox" value="10" /><label for="name10">Node 3.3</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_from_tree_for_multiple_select('name', nodes(:n3).children, :id, :name, [], :level_class => 'level', :inner_class => 'testclass'), "With level and inner class"
<li class="testclass level0"><input id="name8" name="name[]" type="checkbox" value="8" /><label for="name8">Node 3.1</label></li>
<li class="testclass level0"><input id="name9" name="name[]" type="checkbox" value="9" /><label for="name9">Node 3.2</label>\n<ul><li class="testclass level1"><input id="name11" name="name[]" type="checkbox" value="11" /><label for="name11">Node 3.2.1</label></li>
<li class="testclass level1"><input id="name12" name="name[]" type="checkbox" value="12" /><label for="name12">Node 3.2.2</label></li></ul></li>
<li class="testclass level0"><input id="name10" name="name[]" type="checkbox" value="10" /><label for="name10">Node 3.3</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_from_tree_for_multiple_select('name', nodes(:n3).children, :id, :name, [], :level_class => 'level', :initial_level => 2), "With level class and initial level"
<li class="level2"><input id="name8" name="name[]" type="checkbox" value="8" /><label for="name8">Node 3.1</label></li>
<li class="level2"><input id="name9" name="name[]" type="checkbox" value="9" /><label for="name9">Node 3.2</label>\n<ul><li class="level3"><input id="name11" name="name[]" type="checkbox" value="11" /><label for="name11">Node 3.2.1</label></li>
<li class="level3"><input id="name12" name="name[]" type="checkbox" value="12" /><label for="name12">Node 3.2.2</label></li></ul></li>
<li class="level2"><input id="name10" name="name[]" type="checkbox" value="10" /><label for="name10">Node 3.3</label></li>
END
  end
  
  def test_cftfms_level_class_variable
    FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.level_class = 'lvl'
    assert_dom_equal <<END.strip, checkboxes_from_tree_for_multiple_select('name', nodes(:n3).children, :id, :name, []), "Without explicit level class"
<li class="lvl0"><input id="name8" name="name[]" type="checkbox" value="8" /><label for="name8">Node 3.1</label></li>
<li class="lvl0"><input id="name9" name="name[]" type="checkbox" value="9" /><label for="name9">Node 3.2</label>\n<ul><li class="lvl1"><input id="name11" name="name[]" type="checkbox" value="11" /><label for="name11">Node 3.2.1</label></li>
<li class="lvl1"><input id="name12" name="name[]" type="checkbox" value="12" /><label for="name12">Node 3.2.2</label></li></ul></li>
<li class="lvl0"><input id="name10" name="name[]" type="checkbox" value="10" /><label for="name10">Node 3.3</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_from_tree_for_multiple_select('name', nodes(:n3).children, :id, :name, [], :level_class => 'level'), "With explicit level class"
<li class="level0"><input id="name8" name="name[]" type="checkbox" value="8" /><label for="name8">Node 3.1</label></li>
<li class="level0"><input id="name9" name="name[]" type="checkbox" value="9" /><label for="name9">Node 3.2</label>\n<ul><li class="level1"><input id="name11" name="name[]" type="checkbox" value="11" /><label for="name11">Node 3.2.1</label></li>
<li class="level1"><input id="name12" name="name[]" type="checkbox" value="12" /><label for="name12">Node 3.2.2</label></li></ul></li>
<li class="level0"><input id="name10" name="name[]" type="checkbox" value="10" /><label for="name10">Node 3.3</label></li>
END
  end
  
  def test_cftfms_child_method
    assert_dom_equal <<END.strip, checkboxes_from_tree_for_multiple_select('name', nodes(:n3).children, :id, :name, [], :child_method => :alt_children)
<li><input id="name8" name="name[]" type="checkbox" value="8" /><label for="name8">Node 3.1</label></li>
<li><input id="name9" name="name[]" type="checkbox" value="9" /><label for="name9">Node 3.2</label>\n<ul><li><input id="name11" name="name[]" type="checkbox" value="11" /><label for="name11">Node 3.2.1</label></li>
<li><input id="name12" name="name[]" type="checkbox" value="12" /><label for="name12">Node 3.2.2</label></li></ul></li>
<li><input id="name10" name="name[]" type="checkbox" value="10" /><label for="name10">Node 3.3</label></li>
END
  end
  
  def test_cftfms_alternate
    assert_dom_equal <<END.strip, checkboxes_from_tree_for_multiple_select('name', nodes(:n3).children, :id, :name, [], :alternate => true), "With alternate = true"
<li><input id="name8" name="name[]" type="checkbox" value="8" /><label for="name8">Node 3.1</label></li>
<li class="alt"><input id="name9" name="name[]" type="checkbox" value="9" /><label for="name9">Node 3.2</label>\n<ul><li><input id="name11" name="name[]" type="checkbox" value="11" /><label for="name11">Node 3.2.1</label></li>
<li class="alt"><input id="name12" name="name[]" type="checkbox" value="12" /><label for="name12">Node 3.2.2</label></li></ul></li>
<li><input id="name10" name="name[]" type="checkbox" value="10" /><label for="name10">Node 3.3</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_from_tree_for_multiple_select('name', nodes(:n3).children, :id, :name, [], :alternate => true, :initial_alternate => false), "With alternate = true and initial alternate = false"
<li><input id="name8" name="name[]" type="checkbox" value="8" /><label for="name8">Node 3.1</label></li>
<li class="alt"><input id="name9" name="name[]" type="checkbox" value="9" /><label for="name9">Node 3.2</label>\n<ul><li><input id="name11" name="name[]" type="checkbox" value="11" /><label for="name11">Node 3.2.1</label></li>
<li class="alt"><input id="name12" name="name[]" type="checkbox" value="12" /><label for="name12">Node 3.2.2</label></li></ul></li>
<li><input id="name10" name="name[]" type="checkbox" value="10" /><label for="name10">Node 3.3</label></li>
END

    assert_dom_equal <<END.strip, checkboxes_from_tree_for_multiple_select('name', nodes(:n3).children, :id, :name, [], :alternate => true, :initial_alternate => true), "With alternate = true and initial alternate = true"
<li class="alt"><input id="name8" name="name[]" type="checkbox" value="8" /><label for="name8">Node 3.1</label></li>
<li><input id="name9" name="name[]" type="checkbox" value="9" /><label for="name9">Node 3.2</label>\n<ul><li class="alt"><input id="name11" name="name[]" type="checkbox" value="11" /><label for="name11">Node 3.2.1</label></li>
<li><input id="name12" name="name[]" type="checkbox" value="12" /><label for="name12">Node 3.2.2</label></li></ul></li>
<li class="alt"><input id="name10" name="name[]" type="checkbox" value="10" /><label for="name10">Node 3.3</label></li>
END
  end
end
