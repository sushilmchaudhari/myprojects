
Facter.add(:cur_user) do
     setcode do
       %x{/usr/bin/users}.chomp
     end
end


#Facter.add('cur_user') do
#  setcode do
#    Facter::Core::Execution.exec('/bin/users')
#  end
#end
