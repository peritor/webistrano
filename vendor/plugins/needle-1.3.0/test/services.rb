module A
  module B
    module C

      def register_services( container )
        container.namespace( :foo ) do |ns|
          ns.register( :bar ) { "hello" }
        end
      end
      module_function :register_services

      def register_other_services( container )
        container.namespace( :blah ) do |ns|
          ns.register( :baz ) { "hello" }
        end
      end
      module_function :register_other_services

      def register_parameterized_services( container )
        container.define do |b|
          b.baz1 { |c,p,*args| args.join(":") }
          b.baz2( :model=>:prototype ) { |c,p,*a| a.join(":") }
        end
      end
      module_function :register_parameterized_services

    end
  end
end
