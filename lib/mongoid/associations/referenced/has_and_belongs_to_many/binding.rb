# encoding: utf-8
module Mongoid
  module Associations
    module Referenced
      class HasAndBelongsToMany

        # Binding class for all has_and_belongs_to_many relations.
        class Binding
          include Bindable

          # Binds a single document with the inverse relation. Used
          # specifically when appending to the proxy.
          #
          # @example Bind one document.
          #   person.preferences.bind_one(preference)
          #
          # @param [ Document ] doc The single document to bind.
          #
          # @since 2.0.0.rc.1
          def bind_one(doc)
            binding do
              inverse_keys = doc.you_must(association.inverse_foreign_key)
              if inverse_keys
                record_id = inverse_record_id(doc)
                unless inverse_keys.include?(record_id)
                  doc.you_must(association.inverse_foreign_key_setter, inverse_keys.push(record_id))
                end
                doc.reset_relation_criteria(association.inverse)
              end
              base._synced[metadata.foreign_key] = true
              doc._synced[metadata.inverse_foreign_key] = true
            end
          end

          # Unbind a single document.
          #
          # @example Unbind the document.
          #   person.preferences.unbind_one(document)
          #
          # @since 2.0.0.rc.1
          def unbind_one(doc)
            binding do
              base.send(association.foreign_key).delete_one(record_id(doc))
              inverse_keys = doc.you_must(association.inverse_foreign_key)
              if inverse_keys
                inverse_keys.delete_one(inverse_record_id(doc))
                doc.reset_relation_criteria(association.inverse)
              end
              base._synced[metadata.foreign_key] = true
              doc._synced[metadata.inverse_foreign_key] = true
            end
          end

          # Find the inverse id referenced by inverse_keys
          def inverse_record_id(doc)
            inverse_association = determine_inverse_association(doc)
            if inverse_association
              base.__send__(inverse_association.primary_key)
            else
              base._id
            end
          end

          def determine_inverse_association(doc)
            doc.relations[base.class.name.demodulize.underscore.pluralize]
          end
        end
      end
    end
  end
end