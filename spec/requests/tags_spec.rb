require 'rails_helper'

RSpec.describe "Tags", type: :request do
  let!(:headers) { { CONTENT_TYPE: "application/json" } }

  context 'valid requests' do
    context 'without present tags' do
      it 'GET should return empty response' do
        get api_v1_tags_path
        expect(response).to have_http_status(200)
        expect(parse_json(response.body)).to eq({data: []}.as_json)
      end

      it 'POST should create tag without tasks' do
        tag_data = {
          data: {
            id: 'undefined',
            type: 'undefined',
            attributes: { title: 'tag_title_1' }
          }
        }

        post api_v1_tags_path(tag_data), headers: headers

        expect(response).to have_http_status(201)

        expected_response_data = {
          data: {
            id: '1',
            type: 'tags',
            attributes: { title: 'tag_title_1' },
            relationships: { tasks: { data: [] } }
          }
        }

        expect(parse_json(response.body)).to eq(parse_json(expected_response_data.to_json))
      end

      it 'POST should create tag with task' do
        tag_post_data = {
          data: {
            id: 'undefined',
            type: 'undefined',
            attributes: {
              title: 'tag_title_1',
              tasks: ['tag_1_title_1']
            }
          }
        }

        expected_response_data = {
          data: {
            id: '1',
            type: 'tags',
            attributes: { title: 'tag_title_1' },
            relationships: { tasks: { data: [ { id: '1', type: 'tasks'} ] } }
          },
          included: [
            {
              id: '1',
              type: 'tasks',
              attributes: { title: 'tag_1_title_1' },
              relationships: { tags: { data: [ { id: '1', type: 'tags'} ] } }
            }
          ]
        }

        post api_v1_tags_path(tag_post_data), headers: headers
        expect(response).to have_http_status(201)
        expect(parse_json(response.body)).to eq(parse_json(expected_response_data.to_json))
        expect(Tag.active.count).to eq(1)
        expect(Task.active.count).to eq(1)
      end
    end

    context 'with present tags' do
      let!(:tag) { create(:tag) }
      let!(:task) { create(:task) }

      it 'SHOW should return tag' do
        get api_v1_tag_path(tag), headers: headers
        expected_response_data = {
          data: {
            id: "#{tag.id}",
            type: 'tags',
            attributes: { title: "#{tag.title}" },
            relationships: { tasks: { data: [] } }
          }
        }
        expect(response).to have_http_status(200)
        expect(parse_json(response.body)).to eq(parse_json(expected_response_data.to_json))
      end

      it 'PATCH should update tag title' do
        new_tag_title = 'tag_title_1'
        tag_data = {
          data: {
            id: 'undefined',
            type: 'tags',
            attributes: { title: new_tag_title }
          }
        }

        patch api_v1_tag_path(tag, tag_data), headers: headers

        expect(response).to have_http_status(200)

        expected_response_data = {
          data: {
            id: '1',
            type: 'tags',
            attributes: { title: new_tag_title },
            relationships: { tasks: { data: [] } }
          }
        }

        expect(parse_json(response.body)).to eq(parse_json(expected_response_data.to_json))
      end

      it 'PATCH should add tasks' do
        tag_patch_data = {
          data: {
            id: 'undefined',
            type: 'tags',
            attributes: {
              tasks: ['tag_1_title_1']
            }
          }
        }

        expected_response_data = {
          data: {
            id: '1',
            type: 'tags',
            attributes: { title: tag.title },
            relationships: { tasks: { data: [ { id: '2', type: 'tasks'} ] } }
          },
          included: [
            {
              id: '2',
              type: 'tasks',
              attributes: { title: 'tag_1_title_1' },
              relationships: { tags: { data: [ { id: '1', type: 'tags'} ] } }
            }
          ]
        }

        patch api_v1_tag_path(tag, tag_patch_data), headers: headers
        expect(response).to have_http_status(200)
        expect(parse_json(response.body)).to eq(parse_json(expected_response_data.to_json))
        expect(Task.active.count).to eq(2)
      end

      it 'PATCH should not allow to add existing task' do
        tag_patch_data = {
          data: {
            id: 'undefined',
            type: 'tags',
            attributes: {
              tasks: [task.title]
            }
          }
        }

        patch api_v1_tag_path(tag, tag_patch_data), headers: headers
        expect(response).to have_http_status(422)
        expect(parse_json(response.body)).to eq(["Tasks title has already been taken"])
      end

      it 'POST should not allow to add existing tag' do
          tag_post_data = {
          data: {
            id: 'undefined',
            type: 'tags',
            attributes: {
              title: tag.title
            }
          }
        }

        post api_v1_tags_path(tag_post_data), headers: headers
        expect(response).to have_http_status(422)
        expect(parse_json(response.body)).to eq(["Title has already been taken"])
      end

      it 'DELETE should mark tag as deleted' do
        delete api_v1_tag_path(tag), headers: headers
        expect(response).to have_http_status(200)
        expect(parse_json(response.body)).to eq(200)
        expect(Tag.active.count).to eq(0)
      end

      it 'GET should not show deleted tags' do
        tag.mark_as_deleted!
        get api_v1_tags_path
        expect(response).to have_http_status(200)
        expect(parse_json(response.body)).to eq({data: []}.as_json)
      end
    end
  end

  context 'invalid requests' do
    let!(:task) { create(:task) }
    it 'should return 404' do
      get api_v1_tag_path(task), headers: headers
      expect(response).to have_http_status(404)
      expect(parse_json(response.body)).to eq(404)
      expect(Task.active.count).to eq(1)
    end
  end
end
