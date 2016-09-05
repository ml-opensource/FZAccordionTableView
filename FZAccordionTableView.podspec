Pod::Spec.new do |s|
  s.name         = 'FZAccordionTableView'
  s.version      = '0.2.3'
  s.source       = { :git => 'https://github.com/fuzz-productions/FZAccordionTableView.git', :tag => '0.2.3' }
  s.source_files = 'FZAccordionTableView/*.{h,m}'
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.summary      = 'FZAccordionTableView transforms your regular UITableView into an accordion table view.'
  s.author       = { 'Krisjanis Gaidis' => 'noemail@noemail.com'}
  s.homepage     = 'https://github.com/fuzz-productions/FZAccordionTableView'
end